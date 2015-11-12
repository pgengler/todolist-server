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

	def create
		@recurring_task = RecurringTask.create!(recurring_task_params)
		render json: @recurring_task
	end

	def update
		@task = RecurringTask.find(params[:id])
		@task.update(recurring_task_params)
		render json: @task
	end

	def destroy
		@task = RecurringTask.find(params[:id])
		@task.destroy!
		head :no_content
	end

	private
	def recurring_task_params
		params[:recurring_task][:day] = params[:recurring_task][:day_id].to_i
		params.require(:recurring_task).permit(:description, :day)
	end
end
