require 'test_helper'

class TasksTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelpers
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, email: 'foo@example.com', password: 'barbaz')
  end

  test 'requires auth to create a task' do
    list = create(:list, list_type: 'list')

    params = {
      data: {
        attributes: {
          description: 'a new task'
        },
        relationships: {
          list: {
            data: {
              type: 'lists',
              id: list.id
            }
          }
        },
        type: 'tasks'
      }
    }
    json_api_post '/api/v2/tasks', params: params.to_json
    assert_response :unauthorized

    login(@user)
    json_api_post '/api/v2/tasks', params: params.to_json
    assert_response :created
  end

  test 'filters by overdue tasks' do
    last_week = 1.week.ago

    last_week_list = create(:list, :day, name: last_week.strftime('%Y-%m-%d'))
    create_list(:task, 5, done: false, list: last_week_list)
    create_list(:task, 6, done: true, list: last_week_list)

    login(@user)
    json_api_get '/api/v2/tasks?filter[overdue]=true'

    body = JSON.parse(response.body)

    assert_equal body['data'].length, 5
    ids = body['data'].map { |item| item['id'].to_i }
    assert_equal ids, Task.overdue.map(&:id)
  end

  test 'can request sorting by due date' do
    last_week = 1.week.ago
    last_month = 1.month.ago
    last_year = 1.year.ago

    last_week_list = create(:list, :day, name: last_week.strftime('%Y-%m-%d'))
    last_month_list = create(:list, :day, name: last_month.strftime('%Y-%m-%d'))
    last_year_list = create(:list, :day, name: last_year.strftime('%Y-%m-%d'))

    last_month_task = create(:task, list: last_month_list)
    last_year_task = create(:task, list: last_year_list)
    last_week_task = create(:task, list: last_week_list)

    login @user
    json_api_get '/api/v2/tasks?filter[overdue]=true&sort=due-date,plaintext-description'
    assert_response :success

    body = JSON.parse(response.body)
    data = JSON.parse(response.body)['data']

    assert_equal data[0]['id'], last_year_task.id.to_s
    assert_equal data[1]['id'], last_month_task.id.to_s
    assert_equal data[2]['id'], last_week_task.id.to_s
  end

  test 'can request sorting by plain-text description' do
    list = create(:list)
    create :task, list: list, description: '**foo**'
    create :task, list: list, description: '_bar_'
    create :task, list: list, description: 'baz'

    login @user
    json_api_get '/api/v2/tasks?sort=plaintext-description'
    assert_response :success

    data = JSON.parse(response.body)['data']
    assert_equal data[0]['attributes']['description'], '_bar_'
    assert_equal data[1]['attributes']['description'], 'baz'
    assert_equal data[2]['attributes']['description'], '**foo**'
  end

  test 'can filter by tasks due before a given date' do
    last_week = 1.week.ago
    today = DateTime.now

    last_week_list = create(:list, :day, name: last_week.strftime('%Y-%m-%d'))
    unfinished_overdue_tasks = create_list(:task, 5, done: false, list: last_week_list)
    create_list(:task, 6, done: true, list: last_week_list)

    today_list = create(:list, :day, name: today.strftime('%Y-%m-%d'))
    create_list(:task, 4, done: false, list: today_list)

    login(@user)
    json_api_get "/api/v2/tasks?filter[due_before]=#{today.strftime('%Y-%m-%d')}"
    assert_response :success

    body = JSON.parse(response.body)

    assert_equal body['data'].length, 5
    ids = body['data'].map { |item| item['id'].to_i }
    assert_equal ids, unfinished_overdue_tasks.map(&:id)
  end
end
