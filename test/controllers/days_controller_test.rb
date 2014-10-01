require 'test_helper'

class DaysControllerTest < ActionController::TestCase
  test "has an 'index' action" do
    get :index
    assert_response :success
  end
end
