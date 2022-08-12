require 'test_helper'

class TasksTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelpers
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, email: 'foo@example.com', password: 'barbaz')
  end

  test "requires auth to create a task" do
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

  test "filters by overdue tasks" do
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
end
