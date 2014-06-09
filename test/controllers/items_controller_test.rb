require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "index view includes appropriate items" do
    get :index
    body = JSON.parse(response.body)
    assert_equal 2, body['items'].length
  end

end
