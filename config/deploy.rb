# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'todolist-server'
set :repo_url, 'https://github.com/pgengler/todolist-server.git'

set :deploy_to, '/srv/apps/todolist/server'

set :linked_files, %w{.env}

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
