require 'test_helper'

class DaysControllerTest < ActionController::TestCase
	test "has an 'index' action" do
		get :index
		assert_response :success
	end

	test 'can get days for a non-current date' do
		get :index, date: '2014-01-01'
		assert_response :success
		assert_equal '2013-12-31', json_response['days'][0]['date']
	end

	private

	def json_response
		@json_response ||= JSON.parse(response.body)
	end
end
