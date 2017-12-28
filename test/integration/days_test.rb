require 'test_helper'
require 'helpers/integration_test_helpers'

class DaysTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelpers

  test "filters by date" do
    create(:day, date: '2017-12-26')
    create(:day, date: '2017-12-27')
    create(:day, date: '2017-12-28')

    json_api_get '/api/v2/days?filter[date][]=2017-12-26&filter[date][]=2017-12-27'

    body = JSON.parse(response.body)
    days = body['data'].select { |item| item['type'] == 'days' }
    assert_equal 2, days.length
  end

  test "creates days that are requested but don't exist" do
    create(:day, date: '2017-12-26')

    json_api_get '/api/v2/days?filter[date][]=2017-12-26&filter[date][]=2017-12-27'

    body = JSON.parse(response.body)
    days = body['data'].select { |item| item['type'] == 'days' }
    assert_equal 2, days.length
  end

  test "populates newly-created days with the recurring tasks for that day" do
    next_monday = DateTime.now.next_week.next_day(0).strftime('%Y-%m-%d')
    create_list(:recurring_task, 6, day: 1)

    json_api_get "/api/v2/days?filter[date][]=#{next_monday}&include=tasks"

    body = JSON.parse(response.body)
    tasks = body['included'].select { |item| item['type'] == 'tasks' }
    assert_equal 6, tasks.length
  end
end
