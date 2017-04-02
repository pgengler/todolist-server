require 'test_helper'

class DaysControllerTest < ActionController::TestCase
	test "returns the current day when no date is passed" do
		get :index
		assert_equal Date.today.to_s, json_response['day']['date']
	end

	test "returns the specified day when a date is passed" do
		get :index, params: { date: '2014-01-01' }
		assert_equal '2014-01-01', json_response['day']['date']
	end

	test "returns the correct number of days when given an after_days value" do
		get :index, params: { after_days: 3 }
		assert_equal 4, json_response['days'].length
	end

	test "returns the correct days when given an after_days value" do
		get :index, params: { date: '2014-01-01', after_days: 3 }
		assert_equal '2014-01-01', json_response['days'][0]['date']
		assert_equal '2014-01-02', json_response['days'][1]['date']
		assert_equal '2014-01-03', json_response['days'][2]['date']
		assert_equal '2014-01-04', json_response['days'][3]['date']
	end

	test "returns the correct number of days when given a before_days value" do
		get :index, params: { before_days: 2 }
		assert_equal 3, json_response['days'].length
	end

	test "returns the correct days when given a before_days value" do
		get :index, params: { date: '2014-01-02', before_days: 2 }
		assert_equal '2013-12-31', json_response['days'][0]['date']
		assert_equal '2014-01-01', json_response['days'][1]['date']
		assert_equal '2014-01-02', json_response['days'][2]['date']
	end

	test "creates dates that don't exist yet" do
		assert_difference 'Day.count', 5 do
			get :index, params: { date: Date.today.to_s, before_days: 3, after_days: 1 }
		end
	end

	test "returns the 'undated' date when passed 'undated'" do
		get :index, params: { date: 'undated' }
		assert_response :success
		assert_not_nil json_response['day']['id']
		assert_nil json_response['day']['date']
	end

	test "returns a single date via the 'show' action" do
		get :show, params: { id: days(:october_3).id }
		assert_response :success
		assert_equal '2013-10-03', json_response['day']['date']
	end

	private

	def json_response
		@json_response ||= JSON.parse(response.body)
	end
end
