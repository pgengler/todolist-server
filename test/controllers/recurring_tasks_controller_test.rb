require 'test_helper'

class RecurringTasksControllerTest < ActionController::TestCase
  test "can update the description for a task" do
    @task = recurring_tasks(:sunday_task)
    put :update, id: @task, recurring_task: { description: 'Some other thing' }
    assert_equal 'Some other thing', assigns(:task).description
	end

	test "recurring tasks can be deleted" do
		assert_difference('RecurringTask.count', -1) do
			delete :destroy, id: recurring_tasks(:sunday_task)
		end
	end
end
