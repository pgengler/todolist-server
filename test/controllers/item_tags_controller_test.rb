require 'test_helper'

class ItemTagsControllerTest < ActionController::TestCase
	test "has an 'index' action" do
		get :index
		assert_response :success
	end
end