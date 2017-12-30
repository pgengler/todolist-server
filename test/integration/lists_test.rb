require 'test_helper'
require 'helpers/integration_test_helpers'

class ListsTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelpers

  test "filters by date" do
    create(:list, name: '2017-12-26', list_type: 'day')
    create(:list, name: '2017-12-27', list_type: 'day')
    create(:list, name: '2017-12-28', list_type: 'day')
    create(:list, name: 'Other', list_type: 'list')

    json_api_get '/api/v2/lists?filter[date][]=2017-12-26&filter[date][]=2017-12-27'

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 2, body['data'].length
  end

  test "filters by list type" do
    create(:list, name: '2017-12-26', list_type: 'day')
    create(:list, name: '2017-12-27', list_type: 'day')
    create(:list, name: '2017-12-28', list_type: 'day')
    create(:list, name: 'Other', list_type: 'list')

    json_api_get '/api/v2/lists?filter[list-type]=list'

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body['data'].length
  end

  test "creates days that are requested but don't exist" do
    create(:list, name: '2017-12-26')

    json_api_get '/api/v2/lists?filter[date][]=2017-12-26&filter[date][]=2017-12-27'

    body = JSON.parse(response.body)
    assert_equal 2, body['data'].length
  end

  test "populates newly-created days with the recurring tasks for that day" do
    next_monday = DateTime.now.next_week.next_day(0).strftime('%Y-%m-%d')
    recurring_task_list = create(:list, name: 'Monday', list_type: 'recurring-task-day')
    create_list(:task, 6, list_id: recurring_task_list.id)

    json_api_get "/api/v2/lists?filter[date][]=#{next_monday}&include=tasks"

    body = JSON.parse(response.body)
    tasks = body['included'].select { |item| item['type'] == 'tasks' }
    assert_equal 6, tasks.length
  end
end
