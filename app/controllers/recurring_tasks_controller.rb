class RecurringTasksController < ApplicationController
  def index
    @days = [ ]
    RecurringTask.days.each do |name, value|
      @days << {
          id: value,
          day: name,
          recurring_task_ids: RecurringTask.where(day: value).pluck(:id)
      }
    end
    render json: { recurring_task_days: @days, recurring_tasks: RecurringTask.all }
  end
end
