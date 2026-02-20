# V3 Recurring Tasks API Documentation

## Overview

The v3 API introduces a more flexible recurring task system that supports:
- Tasks recurring every N weeks on specific days
- Tasks recurring on multiple days of the week
- Monthly recurring tasks on specific dates or relative days (e.g., "3rd Thursday")
- Per-instance modifications and deletions without affecting the recurrence pattern

## Data Model

### RecurringTaskTemplate
Defines the recurrence pattern and base description for recurring tasks.

Fields:
- `description`: Task description
- `recurrence_rule`: JSON object defining the recurrence pattern
- `start_date`: Date when the recurrence begins
- `end_date`: Optional end date for the recurrence
- `active`: Boolean indicating if the template is active

### RecurringTaskInstance
Represents a specific occurrence of a recurring task.

Fields:
- `recurring_task_template_id`: Reference to the template
- `task_id`: Reference to the created task (when created)
- `scheduled_date`: Date when this instance should occur
- `status`: One of 'pending', 'created', 'skipped', 'deleted'

### RecurringTaskOverride
Stores modifications to specific instances of recurring tasks.

Fields:
- `recurring_task_template_id`: Reference to the template
- `original_date`: The date of the instance being overridden
- `override_type`: One of 'deleted', 'modified', 'rescheduled'
- `override_data`: JSON object with override details

## Recurrence Rule Format

### Weekly Recurrence
```json
{
  "type": "weekly",
  "interval": 1,  // Every N weeks
  "days_of_week": ["monday", "wednesday", "friday"]
}
```

### Monthly Recurrence (Specific Date)
```json
{
  "type": "monthly",
  "interval": 1,  // Every N months
  "day_of_month": 15  // 15th of each month
}
```

### Monthly Recurrence (Relative Day)
```json
{
  "type": "monthly",
  "interval": 1,
  "week_of_month": "third",  // "first", "second", "third", "fourth", "last"
  "day_of_week": "thursday"
}
```

## API Endpoints

### Recurring Task Templates

#### GET /api/v3/recurring-task-templates
List all recurring task templates for the authenticated user.

Query Parameters:
- `filter[active]`: Filter by active status (default: true)

#### POST /api/v3/recurring-task-templates
Create a new recurring task template.

Request Body:
```json
{
  "data": {
    "type": "recurring-task-templates",
    "attributes": {
      "description": "Team standup meeting",
      "start-date": "2025-01-08",
      "end-date": "2025-12-31",
      "recurrence-rule": {
        "type": "weekly",
        "interval": 1,
        "days-of-week": ["monday", "wednesday", "friday"]
      }
    }
  }
}
```

#### PATCH /api/v3/recurring-task-templates/:id
Update a recurring task template. Changes apply to future instances only.

#### DELETE /api/v3/recurring-task-templates/:id
Soft-delete a recurring task template (sets active=false).

#### POST /api/v3/recurring-task-templates/:id/deactivate
Deactivate a recurring task template.

### Recurring Task Instances

#### GET /api/v3/recurring-task-instances
List recurring task instances.

Query Parameters:
- `filter[start_date]`: Show instances on or after this date
- `filter[end_date]`: Show instances on or before this date
- `filter[template_id]`: Filter by template ID
- `filter[status]`: Filter by status

#### GET /api/v3/recurring-task-instances/:id
Get details of a specific instance.

#### POST /api/v3/recurring-task-instances/:id/create-task
Manually create a task for a pending instance.

#### POST /api/v3/recurring-task-instances/:id/skip
Skip a pending instance without creating a task.

### Recurring Task Overrides

#### GET /api/v3/recurring-task-overrides
List all overrides.

Query Parameters:
- `filter[original_date]`: Filter by date
- `filter[override_type]`: Filter by type

#### POST /api/v3/recurring-task-overrides
Create a new override.

Request Body (Delete Instance):
```json
{
  "data": {
    "type": "recurring-task-overrides",
    "attributes": {
      "override-type": "deleted"
    },
    "relationships": {
      "recurring-task-template": {
        "data": { "type": "recurring-task-templates", "id": "123" }
      }
    }
  }
}
```

Request Body (Modify Instance):
```json
{
  "data": {
    "type": "recurring-task-overrides",
    "attributes": {
      "original-date": "2025-01-15",
      "override-type": "modified",
      "override-data": {
        "description": "Team standup - Moved to conference room B"
      }
    },
    "relationships": {
      "recurring-task-template": {
        "data": { "type": "recurring-task-templates", "id": "123" }
      }
    }
  }
}
```

Request Body (Reschedule Instance):
```json
{
  "data": {
    "type": "recurring-task-overrides",
    "attributes": {
      "original-date": "2025-01-15",
      "override-type": "rescheduled",
      "override-data": {
        "new_date": "2025-01-16"
      }
    },
    "relationships": {
      "recurring-task-template": {
        "data": { "type": "recurring-task-templates", "id": "123" }
      }
    }
  }
}
```

#### PATCH /api/v3/recurring-task-overrides/:id
Update override data.

#### DELETE /api/v3/recurring-task-overrides/:id
Remove an override (restores default behavior for that instance).

## Migration Strategy

### For Existing Users

1. Existing weekly recurring tasks (v2) continue to work unchanged
2. When users access the v3 API, they can create new flexible recurring tasks
3. A migration script is available to convert v2 recurring tasks to v3 templates

### Backward Compatibility

- The v2 API remains fully functional
- Day lists continue to populate from both v2 and v3 recurring tasks
- No breaking changes to existing functionality

### Future Deprecation Path

1. Phase 1: Both v2 and v3 APIs available (current state)
2. Phase 2: v2 API marked as deprecated, migration tools provided
3. Phase 3: v2 API removed, all recurring tasks use v3 model

## Examples

### Create a bi-weekly recurring task
```bash
curl -X POST https://api.example.com/api/v3/recurring-task-templates \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "data": {
      "type": "recurring-task-templates",
      "attributes": {
        "description": "Submit timesheet",
        "start-date": "2025-01-10",
        "recurrence-rule": {
          "type": "weekly",
          "interval": 2,
          "days-of-week": ["friday"]
        }
      }
    }
  }'
```

### Delete a single instance
```bash
curl -X POST https://api.example.com/api/v3/recurring-task-overrides \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "data": {
      "type": "recurring-task-overrides",
      "attributes": {
        "original-date": "2025-02-14",
        "override-type": "deleted"
      },
      "relationships": {
        "recurring-task-template": {
          "data": { "type": "recurring-task-templates", "id": "456" }
        }
      }
    }
  }'
```
