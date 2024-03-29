require 'test_helper'
require 'helpers/integration_test_helpers'

class ListsTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelpers
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, email: 'foo@example.com', password: 'barbaz')
  end

  test "returns HTTP 401 when not authorized" do
    create(:list, :day, name: '2018-01-07')

    json_api_get '/api/v2/lists?filter[date][]=2018-01-07'

    assert_response :unauthorized
  end

  test "filters by date" do
    create(:list, :day, name: '2017-12-26')
    create(:list, :day, name: '2017-12-27')
    create(:list, :day, name: '2017-12-28')
    create(:list, name: 'Other', list_type: 'list')

    login(@user)
    json_api_get '/api/v2/lists?filter[date][]=2017-12-26&filter[date][]=2017-12-27'

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 2, body['data'].length
  end

  test "filters by list type" do
    create(:list, :day, name: '2017-12-26')
    create(:list, :day, name: '2017-12-27')
    create(:list, :day, name: '2017-12-28')
    create(:list, name: 'Other', list_type: 'list')

    login(@user)
    json_api_get '/api/v2/lists?filter[list-type]=list'

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body['data'].length
  end

  test "creates days that are requested but don't exist" do
    create(:list, :day, name: '2017-12-26')

    login(@user)
    json_api_get '/api/v2/lists?filter[date][]=2017-12-26&filter[date][]=2017-12-27'

    body = JSON.parse(response.body)
    assert_equal 2, body['data'].length
  end

  test "populates newly-created days with the recurring tasks for that day" do
    next_monday = DateTime.now.next_week.next_day(0).strftime('%Y-%m-%d')
    recurring_task_list = create(:list, :recurring_task_day, name: 'Monday')
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
    assert_no_difference 'List.unscoped.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :no_content
    list.reload
    assert_equal true, list.deleted
  end

  test "trying to DELETE a non-empty 'list' list is an error" do
    list = create(:list, list_type: 'list')
    create_list :task, 10, list: list
    login @user

    assert_no_difference 'List.unscoped.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :unprocessable_entity
    list.reload
    assert_equal false, list.deleted
  end

  test "trying to DELETE a 'day' list is an error" do
    list = create(:list, :day, name: '2022-06-12')
    login @user

    assert_no_difference 'List.unscoped.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :unprocessable_entity
    list.reload
    assert_equal false, list.deleted
  end

  test "trying to DELETE a 'recurring-task-day' list is an error" do
    list = create(:list, :recurring_task_day)
    login @user

    assert_no_difference 'List.unscoped.count' do
      json_api_delete "/api/v2/lists/#{list.id}"
    end
    assert_response :unprocessable_entity
    list.reload
    assert_equal false, list.deleted
  end

  test "deleted lists are not returned in index response" do
    create :list, name: 'Active List', list_type: 'list'
    deleted_list = create(:list, name: 'Deleted List', list_type: 'list')
    deleted_list.destroy!
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

    assert_no_difference 'List.unscoped.count' do
      json_api_post '/api/v2/lists', params: params.to_json
    end
    assert_response :unprocessable_entity
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

    assert_no_difference 'List.unscoped.count' do
      json_api_post '/api/v2/lists', params: params.to_json
    end
    assert_response :unprocessable_entity
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

    assert_no_difference 'List.unscoped.count' do
      json_api_post '/api/v2/lists', params: params.to_json
    end
    assert_response :unprocessable_entity
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

  test "cannot edit a 'day'-type list via PATCH" do
    login @user

    list = create(:list, :day)

    params = {
      data: {
        attributes: {
          name: 'foobar',
          'list-type': 'day',
        },
        id: list.id,
        type: 'lists'
      }
    }

    json_api_patch "/api/v2/lists/#{list.id}", params: params.to_json
    assert_response :unprocessable_entity
  end

  test "cannot edit a 'recurring-task-day'-type list via PATCH" do
    login @user

    list = create(:list, :recurring_task_day)

    params = {
      data: {
        attributes: {
          name: 'foobar',
          'list-type': 'recurring-task-day',
        },
        id: list.id,
        type: 'lists'
      }
    }

    json_api_patch "/api/v2/lists/#{list.id}", params: params.to_json
    assert_response :unprocessable_entity
  end

  test "cannot change list_type of a 'list'-type list via PATCH" do
    login @user

    list = create(:list, name: 'foobar')

    params = {
      data: {
        attributes: {
          name: 'foobar',
          'list-type': 'day',
        },
        id: list.id,
        type: 'lists'
      }
    }

    json_api_patch "/api/v2/lists/#{list.id}", params: params.to_json

    assert_response :unprocessable_entity
  end

  test "can change the name of a 'list'-type list via PATCH" do
    login @user

    list = create(:list, name: 'foobar')

    params = {
      data: {
        attributes: {
          name: 'baz',
          'list-type': 'list',
        },
        id: list.id,
        type: 'lists'
      }
    }

    json_api_patch "/api/v2/lists/#{list.id}", params: params.to_json
    assert_response :success

    list.reload
    assert_equal 'baz', list.name
  end
end
