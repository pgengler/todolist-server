require 'test_helper'

class RecurringTasksControllerTest < ActionController::TestCase
  test "can update the description for a task" do
    @task = recurring_tasks(:sunday_task)
    put :update, params: { id: @task, recurring_task: { description: 'Some other thing' } }
    assert_equal 'Some other thing', assigns(:task).description
  end

  test "returns JSON representation of the task after updating it" do
    put :update, params: { id: recurring_tasks(:sunday_task), recurring_task: { description: 'A new description' } }

    assert_response :ok
    json_response = JSON.parse(response.body)

    assert_equal 'A new description', json_response['recurring_task']['description']
  end

  test "recurring tasks can be deleted" do
    assert_difference('RecurringTask.count', -1) do
      delete :destroy, params: { id: recurring_tasks(:sunday_task) }
    end
  end

  test "returns the correct status code when deleting a recurring task" do
    delete :destroy, params: { id: recurring_tasks(:sunday_task) }
    assert_response :no_content
  end

  test "recurring tasks can be created" do
    assert_difference('RecurringTask.count') do
      post :create, params: { recurring_task: { day_id: 0, description: 'A new task for Sunday' } }
    end
    assert_equal 'A new task for Sunday', assigns(:recurring_task).description
  end
end
