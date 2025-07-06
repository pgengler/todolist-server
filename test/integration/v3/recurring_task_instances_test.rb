require 'test_helper'

class V3::RecurringTaskInstancesTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @template = create(:recurring_task_template, user: @user)
    @other_template = create(:recurring_task_template, user: @other_user)
    @headers = {
      'Content-Type': 'application/vnd.api+json',
      'Accept': 'application/vnd.api+json'
    }
    sign_in @user
  end

  # GET /api/v3/recurring-task-instances
  test "should list user's recurring task instances" do
    instance1 = create(:recurring_task_instance, 
      recurring_task_template: @template,
      scheduled_date: Date.parse('2025-01-15')
    )
    instance2 = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: Date.parse('2025-01-22')
    )
    other_instance = create(:recurring_task_instance,
      recurring_task_template: @other_template
    )

    get '/api/v3/recurring-task-instances', headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 2, json['data'].length
    ids = json['data'].map { |i| i['id'] }
    assert_includes ids, instance1.id.to_s
    assert_includes ids, instance2.id.to_s
    assert_not_includes ids, other_instance.id.to_s
  end

  test "should filter by template_id" do
    template2 = create(:recurring_task_template, user: @user)
    instance1 = create(:recurring_task_instance, recurring_task_template: @template)
    instance2 = create(:recurring_task_instance, recurring_task_template: template2)

    get "/api/v3/recurring-task-instances?filter[template_id]=#{@template.id}", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 1, json['data'].length
    assert_equal instance1.id.to_s, json['data'][0]['id']
  end

  test "should filter by scheduled_date" do
    date = Date.parse('2025-01-15')
    instance1 = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date
    )
    instance2 = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date + 1.day
    )

    get "/api/v3/recurring-task-instances?filter[scheduled_date]=2025-01-15", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 1, json['data'].length
    assert_equal instance1.id.to_s, json['data'][0]['id']
  end

  test "should filter by status" do
    pending = create(:recurring_task_instance,
      recurring_task_template: @template,
      status: 'pending'
    )
    created = create(:recurring_task_instance,
      recurring_task_template: @template,
      status: 'created'
    )

    get "/api/v3/recurring-task-instances?filter[status]=pending", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 1, json['data'].length
    assert_equal pending.id.to_s, json['data'][0]['id']
  end

  # GET /api/v3/recurring-task-instances/:id
  test "should show recurring task instance" do
    list = create(:list, name: '2025-01-15', list_type: 'day')
    task = create(:task, list: list)
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: Date.parse('2025-01-15'),
      status: 'created',
      task: task
    )

    get "/api/v3/recurring-task-instances/#{instance.id}", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal instance.id.to_s, json.dig('data', 'id')
    assert_equal '2025-01-15', json.dig('data', 'attributes', 'scheduled-date')
    assert_equal 'created', json.dig('data', 'attributes', 'status')
    assert_equal task.id.to_s, json.dig('data', 'relationships', 'task', 'data', 'id')
  end

  test "should not show other user's instance" do
    instance = create(:recurring_task_instance, recurring_task_template: @other_template)

    get "/api/v3/recurring-task-instances/#{instance.id}", headers: @headers
    
    assert_response :not_found
  end

  # POST /api/v3/recurring-task-instances/:id/create-task
  test "should create task from pending instance" do
    date = Date.parse('2025-01-15')
    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'pending'
    )

    assert_difference 'Task.count', 1 do
      post "/api/v3/recurring-task-instances/#{instance.id}/create-task",
        params: {
          data: {
            attributes: {
              'list-id': list.id
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :success
    json = JSON.parse(response.body)
    
    instance.reload
    assert_equal 'created', instance.status
    assert_not_nil instance.task
    assert_equal list, instance.task.list
    assert_equal @template.description, instance.task.description
  end

  test "should not create task from already created instance" do
    date = Date.parse('2025-01-15')
    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    task = create(:task, list: list)
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'created',
      task: task
    )

    assert_no_difference 'Task.count' do
      post "/api/v3/recurring-task-instances/#{instance.id}/create-task",
        params: {
          data: {
            attributes: {
              'list-id': list.id
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json['errors'].any? { |e| e['detail'].include?('already created') }
  end

  test "should not create task for wrong date list" do
    date = Date.parse('2025-01-15')
    wrong_date = Date.parse('2025-01-16')
    list = create(:list, name: wrong_date.to_s, list_type: 'day', user: @user)
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'pending'
    )

    assert_no_difference 'Task.count' do
      post "/api/v3/recurring-task-instances/#{instance.id}/create-task",
        params: {
          data: {
            attributes: {
              'list-id': list.id
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json['errors'].any? { |e| e['detail'].include?('does not match') }
  end

  test "should create task with modified description from override" do
    date = Date.parse('2025-01-15')
    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: date,
      override_type: 'modified',
      override_data: { 'description' => 'Special meeting today' }
    )
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'pending'
    )

    post "/api/v3/recurring-task-instances/#{instance.id}/create-task",
      params: {
        data: {
          attributes: {
            'list-id': list.id
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :success
    
    instance.reload
    assert_equal 'Special meeting today', instance.task.description
  end

  # POST /api/v3/recurring-task-instances/:id/skip
  test "should skip pending instance" do
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      status: 'pending'
    )

    post "/api/v3/recurring-task-instances/#{instance.id}/skip", headers: @headers
    
    assert_response :success
    
    instance.reload
    assert_equal 'skipped', instance.status
  end

  test "should not skip already created instance" do
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      status: 'created',
      task: create(:task)
    )

    post "/api/v3/recurring-task-instances/#{instance.id}/skip", headers: @headers
    
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json['errors'].any? { |e| e['detail'].include?('already created') }
  end

  test "should not skip other user's instance" do
    instance = create(:recurring_task_instance, recurring_task_template: @other_template)

    post "/api/v3/recurring-task-instances/#{instance.id}/skip", headers: @headers
    
    assert_response :not_found
  end

  # Authentication tests
  test "should require authentication" do
    sign_out @user

    get '/api/v3/recurring-task-instances', headers: @headers
    assert_response :unauthorized

    instance = create(:recurring_task_instance, recurring_task_template: @template)
    post "/api/v3/recurring-task-instances/#{instance.id}/create-task", headers: @headers
    assert_response :unauthorized
  end
end
