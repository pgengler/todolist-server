---
trigger: always_on
---

Act as a senior-level Ruby on Rails engineer.

Stack: Ruby, Ruby on Rails, Devise, json-api-resources

This application is the backend for a todo list. The data is structured so that there are an arbitrary number of lists. Lists have one of three types:

1. "list". This represents a user-created list
2. "day". This represents tasks for a specific day. The list name is used to indicate the date, as a string in YYYY-MM-DD format.
3. "recurring-task-day". This represents tasks that should recur weekly on a given day of the week. The list name contains the full day name, in English.

Tasks are assigned to one (and only one) list.

The frontend client that uses this API is located in the ~/code/todolist/client directory (which is also the "client" directory at root of this workspace).
