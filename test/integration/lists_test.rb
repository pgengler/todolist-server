require 'test_helper'
require 'helpers/integration_test_helpers'

class ListsTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelpers
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, email: 'foo@example.com', password: 'barbaz')
  end

  test "returns HTTP 401 when not authorized" do
    create(:list, name: '2018-01-07', list_type: 'day')

    json_api_get '/api/v2/lists?filter[date][]=2018-01-07'

    assert_response :unauthorized
  end

  test "filters by date" do
    create(:list, name: '2017-12-26', list_type: 'day')
    create(:list, name: '2017-12-27', list_type: 'day')
    create(:list, name: '2017-12-28', list_type: 'day')
    create(:list, name: 'Other', list_type: 'list')

    login(@user)
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

    login(@user)
    json_api_get '/api/v2/lists?filter[list-type]=list'

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body['data'].length
  end

  test "creates days that are requested but don't exist" do
    create(:list, name: '2017-12-26')

    login(@user)
    json_api_get '/api/v2/lists?filter[date][]=2017-12-26&filter[date][]=2017-12-27'

    body = JSON.parse(response.body)
    assert_equal 2, body['data'].length
  end

  test "populates newly-created days with the recurring tasks for that day" do
    next_monday = DateTime.now.next_week.next_day(0).strftime('%Y-%m-%d')
    recurring_task_list = create(:list, name: 'Monday', list_type: 'recurring-task-day')
    create_list(:task, 6, list_id: recurring_task_list.id)

    login(@user)
    json_api_get "/api/v2/lists?filter[date][]=#{next_monday}&include=tasks"

    body = JSON.parse(response.body)
    tasks = body['included'].select { |item| item['type'] == 'tasks' }
    assert_equal 6, tasks.length
  end

  test "trying to DELETE an empty 'list' list soft-deletes the list" do
    list = create(:list, list_type: 'list')

    login @user
    assert_equal list.deleted, false
    assert_no_difference 'List.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :success
    list.reload
    assert_equal true, list.deleted
  end

  test "trying to DELETE a non-empty 'list' list is an error" do
    list = create(:list, list_type: 'list')
    create_list :task, 10, list: list
    login @user

    assert_no_difference 'List.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :unprocessable_entity
    list.reload
    assert_equal false, list.deleted
  end

  test "trying to DELETE a 'day' list is an error" do
    list = create(:list, name: '2022-06-12', list_type: 'day')
    login @user

    assert_no_difference 'List.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :unprocessable_entity
    list.reload
    assert_equal false, list.deleted
  end

  test "trying to DELETE a 'recurring-task-day' list is an error" do
    list = create(:list, list_type: 'recurring-task-day')
    login @user

    assert_no_difference 'List.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :unprocessable_entity
    list.reload
    assert_equal false, list.deleted
  end

  test "deleted lists are not returned in index response" do
    create :list, name: 'Active List', list_type: 'list'
    create :list, name: 'Deleted List', list_type: 'list', deleted: true
    login @user

    json_api_get '/api/v2/lists?filter[list-type]=list'
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body['data'].length
    assert_equal 'Active List', body['data'][0]['attributes']['name']
  end

  test "trying to create a new 'day'-type list via POST fails" do
    login @user

    params = {
      data: {
        attributes: {
          name: '2022-08-10',
          'list-type': 'day'
        },
        type: 'lists'
      }
    }

    assert_no_difference 'List.count' do
      json_api_post '/api/v2/lists', params: params.to_json
    end
    assert_response :bad_request
  end

  test "trying to create a new 'recurring-task-day' list via POST fails" do
    login @user

    params = {
      data: {
        attributes: {
          name: '2022-08-10',
          'list-type': 'recurring-task-day'
        },
        type: 'lists'
      }
    }

    assert_no_difference 'List.count' do
      json_api_post '/api/v2/lists', params: params.to_json
    end
    assert_response :bad_request
  end

  test "trying to create a new list with an unknown type via POST fails" do
    login @user

    params = {
      data: {
        attributes: {
          name: '2022-08-10',
          'list-type': 'foobar'
        },
        type: 'lists'
      }
    }

    assert_no_difference 'List.count' do
      json_api_post '/api/v2/lists', params: params.to_json
    end
    assert_response :bad_request
  end

  test "can create a new 'list'-type list via POST" do
    login @user

    params = {
      data: {
        attributes: {
          name: '2022-08-10',
          'list-type': 'list'
        },
        type: 'lists'
      }
    }

    assert_difference 'List.count', 1 do
      json_api_post '/api/v2/lists', params: params.to_json
    end
    assert_response :created
  end
end
