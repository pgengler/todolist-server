class TasksController < ApplicationController
  before_action :doorkeeper_authorize!

  def skip
    task = Task.find(params[:id])
    task.skip!
    head :no_content
  end

  def modify_instance
    task = Task.find(params[:id])
    task.modify_instance!(task_params)
    render json: serialize_task(task)
  end

  def update_this_and_future
    task = Task.find(params[:id])
    task.update_this_and_future!(task_params)
    render json: serialize_task(task)
  end

  def delete_this_and_future
    task = Task.find(params[:id])
    task.delete_this_and_future!
    head :no_content
  end

  private

  def task_params
    params.require(:data).require(:attributes).permit(:description, :notes)
  end

  def serialize_task(task)
    JSONAPI::ResourceSerializer.new(TaskResource).serialize_to_hash(TaskResource.new(task, nil))
  end
end
