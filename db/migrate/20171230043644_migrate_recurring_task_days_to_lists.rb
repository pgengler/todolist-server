class MigrateRecurringTaskDaysToLists < ActiveRecord::Migration[5.0]
  def up
    RecurringTaskDay.all.each do |day|
      list = List.create!(name: day.day.to_s.capitalize, list_type: 'recurring-task-day')
      day.recurring_tasks.all.each do |task|
        list.tasks.create!(description: task.description, done: false)
      end
    end
  end

  def down
    RecurringTaskDay.all.each do |day|
      List.where(name: day.day.to_s.capitalize, list_type: 'recurring-task-day').destroy_all
    end
  end
end
