class RecurringTasksController < ApplicationController
	def index
		@days = [ ]
		RecurringTask.days.each do |name, value|
			@days << {
					id: value,
					day: name.titleize,
					recurring_task_ids: RecurringTask.where(day: value).pluck(:id)
			}
		end
		render json: { recurring_task_days: @days, recurring_tasks: RecurringTask.all }
	end

	def update
		@task = RecurringTask.find(params[:id])
		@task.update(recurring_task_params)
	end

	def destroy
		@task = RecurringTask.find(params[:id])
		@task.destroy!
	end

	private
	def recurring_task_params
		params.require(:recurring_task).permit(:description)
	end
end
