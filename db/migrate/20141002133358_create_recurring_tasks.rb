class CreateRecurringTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :recurring_tasks do |t|
      t.integer :day
      t.string :description

      t.timestamps
    end
  end
end
