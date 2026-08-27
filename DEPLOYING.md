# Deploying the Todolist Server

This document covers how to deploy the todolist server application using Kamal 2.

## Architecture

```
Internet → nginx (SSL termination) → kamal-proxy (port 8081) → Rails container (Thruster + Puma)
                                                                        ↓
                                                              PostgreSQL 16 (port 5435)
```

- **nginx** handles SSL termination and proxies HTTP to kamal-proxy on port 8081.
- **kamal-proxy** manages zero-downtime deploys and routes traffic to the Rails container.
- **Thruster** sits inside the container in front of Puma, providing X-Sendfile acceleration and asset caching.
- **PostgreSQL 16** runs on port 5435 on the same server.

## Prerequisites

### 1. Container Registry Access

The app uses GitHub Container Registry (ghcr.io). You need:

- A GitHub Personal Access Token (PAT) with `write:packages` scope.
- Set it as `KAMAL_REGISTRY_PASSWORD` in your local environment before deploying.

### 2. SSH Access

Ensure your SSH key is authorized for the `apps` user on `hyperion.pgengler.net`:

```bash
ssh-copy-id apps@hyperion.pgengler.net
```

### 3. Rails Master Key

The `config/master.key` file is used to decrypt `config/credentials.yml.enc`. This file is gitignored and must exist on your local machine. If you don't have it yet, generate one:

```bash
bin/rails credentials:edit
```

This will create both `config/master.key` and `config/credentials.yml.enc`. Add the following to the credentials file:

```yaml
secret_key_base: <generate with `bin/rails secret`>
```

### 4. Database Password

The PostgreSQL `todolist` user's password must be available as `DB_PASSWORD` in your local environment.

### 5. Kamal Proxy Configuration

The kamal-proxy on the server must be configured to listen on port 8081 (not the default 80/443). Since other apps on the server already use kamal-proxy, it should already be running on port 8081. If not, configure it:

```bash
kamal proxy boot_config set --http-port 8081 --https-port 8443
kamal proxy reboot
```

> **Note:** The `proxy.run.http_port` setting in `config/deploy.yml` handles this automatically for new proxy installations.

### 6. nginx Configuration

nginx should be configured to terminate SSL and proxy to kamal-proxy on port 8081. A typical server block:

```nginx
server {
    listen 443 ssl;
    server_name todolist-server.pgengler.net;  # or your domain

    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Initial Setup

Before your first deploy, ensure all prerequisites are met, then run:

```bash
# Set up secrets in your local environment
export KAMAL_REGISTRY_PASSWORD=<your GitHub PAT>
export DB_PASSWORD=<postgres todolist user password>

# First-time setup: installs Docker on the server (if needed), boots proxy, and deploys
bundle exec kamal setup
```

`kamal setup` will:
1. Install Docker on the server if not already present.
2. Boot kamal-proxy (if not already running).
3. Build the Docker image locally and push it to ghcr.io.
4. Pull the image on the server and start the container.
5. Run the database entrypoint (`bin/docker-entrypoint` runs `rails db:prepare`).

## Subsequent Deploys

After the initial setup, deploy updates with:

```bash
# Set secrets (if not already in your environment)
export KAMAL_REGISTRY_PASSWORD=<your GitHub PAT>
export DB_PASSWORD=<postgres todolist user password>

# Deploy the latest code
bundle exec kamal deploy
```

Kamal performs a zero-downtime deploy: it boots the new container, health-checks it via the `/up` endpoint, then switches traffic to the new container and drains the old one.

## Common Commands

```bash
# View application logs (live)
bundle exec kamal app logs -f

# View kamal-proxy logs
bundle exec kamal proxy logs

# Open a Rails console on the server
bundle exec kamal console

# Run a command inside the app container
bundle exec kamal app exec 'bin/rails db:migrate:status'

# Check deployment configuration
bundle exec kamal config

# Show details about the current deployment
bundle exec kamal details

# Rollback to the previous version
bundle exec kamal app rollback

# Stop the app
bundle exec kamal app stop

# Remove the app from the server
bundle exec kamal app remove
```

## Secrets Management

Secrets are managed via `.kamal/secrets`, which contains references (safe to commit). The actual values are resolved from environment variables on the deploying machine:

| Secret | Description |
|--------|-------------|
| `KAMAL_REGISTRY_PASSWORD` | GitHub Container Registry access token |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` (auto-resolved from the file) |
| `DB_PASSWORD` | PostgreSQL password for the `todolist` user |

## Environment Variables

The following environment variables are injected into the container (defined in `config/deploy.yml`):

| Variable | Value | Description |
|----------|-------|-------------|
| `RAILS_LOG_TO_STDOUT` | `1` | Send logs to stdout for Docker log collection |
| `DB_HOST` | `127.0.0.1` | PostgreSQL host |
| `DB_PORT` | `5435` | PostgreSQL 16 port |
| `RAILS_MASTER_KEY` | (secret) | Decrypts `config/credentials.yml.enc` |
| `DB_PASSWORD` | (secret) | PostgreSQL password |

## Database

The app connects to PostgreSQL 16 on port 5435. The database connection is configured in `config/database.yml` and uses the `DB_HOST`, `DB_PORT`, and `DB_PASSWORD` environment variables.

See `MIGRATING_DATABASE.md` for instructions on migrating data from the old PostgreSQL 9.4 instance to the new PostgreSQL 16 instance.

## Troubleshooting

### Container won't start

Check the app logs:
```bash
bundle exec kamal app logs
```

Common issues:
- Missing `RAILS_MASTER_KEY` — ensure `config/master.key` exists locally.
- Database connection failure — verify PostgreSQL 16 is running on port 5435 and the `todolist` user has access.
- Port conflict — ensure kamal-proxy is running on port 8081 and nginx is proxying to it.

### Health check failing

The health check hits `/up` on the container. If it fails, Kamal will not switch traffic to the new container. Check:
```bash
bundle exec kamal app logs
```

The `/up` endpoint returns `{ "status": "ok" }` with a 200 status code.

### Proxy issues

If kamal-proxy is not running or misconfigured:
```bash
bundle exec kamal proxy logs
bundle exec kamal proxy boot
```
