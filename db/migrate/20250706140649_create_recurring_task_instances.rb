class CreateRecurringTaskInstances < ActiveRecord::Migration[5.2]
  def change
    create_table :recurring_task_instances do |t|
      t.references :recurring_task_template, null: false, foreign_key: true
      t.references :task, foreign_key: true
      t.date :scheduled_date, null: false
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :recurring_task_instances, :scheduled_date
    add_index :recurring_task_instances, :status
    add_index :recurring_task_instances, [:recurring_task_template_id, :scheduled_date], 
              unique: true, name: 'index_recurring_instances_on_template_and_date'
  end
end
