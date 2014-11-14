require 'test_helper'

class DaysControllerTest < ActionController::TestCase
	test "has an 'index' action" do
		get :index
		assert_response :success
	end

	test "returns the current day when no date is passed" do
		get :index
		assert_equal Date.today.to_s, json_response['days'][0]['date']
	end

	test "returns the specified day when a date is passed" do
		get :index, date: '2014-01-01'
		assert_equal '2014-01-01', json_response['days'][0]['date']
	end

	test "returns no other days when after_days and before_days are not passed" do
		get :index
		assert_equal 1, json_response['days'].length
	end

	test "returns the correct number of days when given an after_days value" do
		get :index, after_days: 3
		assert_equal 4, json_response['days'].length
	end

	test "returns the correct days when given an after_days value" do
		get :index, date: '2014-01-01', after_days: 3
		assert_equal '2014-01-01', json_response['days'][0]['date']
		assert_equal '2014-01-02', json_response['days'][1]['date']
		assert_equal '2014-01-03', json_response['days'][2]['date']
		assert_equal '2014-01-04', json_response['days'][3]['date']
	end

	test "returns the correct number of days when given a before_days value" do
		get :index, before_days: 2
		assert_equal 3, json_response['days'].length
	end

	test "returns the correct days when given a before_days value" do
		get :index, date: '2014-01-02', before_days: 2
		assert_equal '2013-12-31', json_response['days'][0]['date']
		assert_equal '2014-01-01', json_response['days'][1]['date']
		assert_equal '2014-01-02', json_response['days'][2]['date']
	end

	test "returns a single date via the 'show' action" do
		get :show, date: '2014-11-01'
		assert_response :success
		assert_equal '2014-11-01', json_response['day']['date']
	end

	private

	def json_response
		@json_response ||= JSON.parse(response.body)
	end
end
