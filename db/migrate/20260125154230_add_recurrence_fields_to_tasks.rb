class AddRecurrenceFieldsToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :recurrence_rule, foreign_key: true, null: true

    # The date this instance was originally scheduled for
    add_column :tasks, :original_date, :date

    # True if this specific instance was individually modified
    add_column :tasks, :instance_modified, :boolean, default: false

    # True if this instance was skipped/deleted
    add_column :tasks, :skipped, :boolean, default: false

    add_index :tasks, [:recurrence_rule_id, :original_date], unique: true, where: 'recurrence_rule_id IS NOT NULL'
  end
end
