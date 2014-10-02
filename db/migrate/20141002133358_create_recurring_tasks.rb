class CreateRecurringTasks < ActiveRecord::Migration
  def change
    create_table :recurring_tasks do |t|
      t.integer :day
      t.string :description

      t.timestamps
    end
  end
end
