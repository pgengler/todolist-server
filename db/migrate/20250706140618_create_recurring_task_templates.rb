class CreateRecurringTaskTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :recurring_task_templates do |t|
      t.string :description, null: false
      t.integer :user_id, null: false
      t.jsonb :recurrence_rule, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :recurring_task_templates, :user_id
    add_index :recurring_task_templates, :active
    add_index :recurring_task_templates, :start_date
  end
end
