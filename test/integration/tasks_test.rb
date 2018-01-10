require 'test_helper'

class TasksTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelpers
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, email: 'foo@example.com', password: 'barbaz')
  end

  test "requires auth to create a task" do
    list = create(:list)

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
end
