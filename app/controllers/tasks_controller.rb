class TasksController < ApplicationController
	def index
		render json: Task.all
	end

	def create
		@task = Task.create!(task_params)
		render json: @task, status: :created, location: @task
	end

	def show
		@task = Task.find(params[:id])
		render json: @task
	end

	def update
		@task = Task.find(params[:id])
		@task.update(task_params)
		render json: @task, location: @task
	end

	private

	def task_params
		params.required(:task).permit(:description, :done, :day_id)
	end
end
