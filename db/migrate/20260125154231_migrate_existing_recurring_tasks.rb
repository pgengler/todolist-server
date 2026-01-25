class MigrateExistingRecurringTasks < ActiveRecord::Migration[6.0]
  def up
    return unless table_exists?(:recurring_tasks)

    execute <<-SQL
      INSERT INTO recurrence_rules (description, recurrence_type, day_of_week, created_at, updated_at)
      SELECT description, 'weekly', day, NOW(), NOW()
      FROM recurring_tasks
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM recurrence_rules
      WHERE recurrence_type = 'weekly'
      AND description IN (SELECT description FROM recurring_tasks)
    SQL
  end
end
