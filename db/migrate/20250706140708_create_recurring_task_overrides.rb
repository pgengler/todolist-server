class CreateRecurringTaskOverrides < ActiveRecord::Migration[5.2]
  def change
    create_table :recurring_task_overrides do |t|
      t.references :recurring_task_template, null: false, foreign_key: true
      t.date :original_date, null: false
      t.string :override_type, null: false # 'deleted', 'modified', 'rescheduled'
      t.jsonb :override_data, default: {}

      t.timestamps
    end

    add_index :recurring_task_overrides, :original_date
    add_index :recurring_task_overrides, [:recurring_task_template_id, :original_date], 
              unique: true, name: 'index_overrides_on_template_and_date'
  end
end
