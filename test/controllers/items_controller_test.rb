require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "index view includes appropriate items" do
    get :index
    items = JSON.parse(response.body)
    p items
    p response.body
    assert_equal 2, items.length
  end

end
