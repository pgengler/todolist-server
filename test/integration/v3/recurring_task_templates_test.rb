require 'test_helper'

class V3::RecurringTaskTemplatesTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @headers = {
      'Content-Type': 'application/vnd.api+json',
      'Accept': 'application/vnd.api+json'
    }
    sign_in @user
  end

  # GET /api/v3/recurring-task-templates
  test "should list user's recurring task templates" do
    template1 = create(:recurring_task_template, user: @user, description: "My task")
    template2 = create(:recurring_task_template, user: @user, description: "Another task")
    other_template = create(:recurring_task_template, user: @other_user, description: "Other user task")

    get '/api/v3/recurring-task-templates', headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 2, json['data'].length
    descriptions = json['data'].map { |t| t.dig('attributes', 'description') }
    assert_includes descriptions, "My task"
    assert_includes descriptions, "Another task"
    assert_not_includes descriptions, "Other user task"
  end

  test "should filter by active status" do
    active = create(:recurring_task_template, user: @user, active: true)
    inactive = create(:recurring_task_template, user: @user, active: false)

    get '/api/v3/recurring-task-templates?filter[active]=true', headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json['data'].length
    assert_equal active.id.to_s, json['data'][0]['id']
  end

  # GET /api/v3/recurring-task-templates/:id
  test "should show recurring task template" do
    template = create(:recurring_task_template, 
      user: @user,
      description: "Weekly standup",
      start_date: Date.parse('2025-01-06'),
      recurrence_rule: {
        type: 'weekly',
        interval: 1,
        days_of_week: ['monday', 'wednesday', 'friday']
      }
    )

    get "/api/v3/recurring-task-templates/#{template.id}", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal template.id.to_s, json.dig('data', 'id')
    assert_equal 'Weekly standup', json.dig('data', 'attributes', 'description')
    assert_equal '2025-01-06', json.dig('data', 'attributes', 'start-date')
    
    rule = json.dig('data', 'attributes', 'recurrence-rule')
    assert_equal 'weekly', rule['type']
    assert_equal 1, rule['interval']
    assert_equal ['monday', 'wednesday', 'friday'], rule['days-of-week']
  end

  test "should not show other user's template" do
    template = create(:recurring_task_template, user: @other_user)

    get "/api/v3/recurring-task-templates/#{template.id}", headers: @headers
    
    assert_response :not_found
  end

  # POST /api/v3/recurring-task-templates
  test "should create weekly recurring task template" do
    assert_difference 'RecurringTaskTemplate.count', 1 do
      post '/api/v3/recurring-task-templates', 
        params: {
          data: {
            type: 'recurring-task-templates',
            attributes: {
              description: 'Team standup',
              'start-date': '2025-01-08',
              'recurrence-rule': {
                type: 'weekly',
                interval: 1,
                'days-of-week': ['monday', 'wednesday', 'friday']
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :created
    json = JSON.parse(response.body)
    
    template = RecurringTaskTemplate.last
    assert_equal @user, template.user
    assert_equal 'Team standup', template.description
    assert_equal Date.parse('2025-01-08'), template.start_date
    assert_equal 'weekly', template.recurrence_rule['type']
    assert_equal ['monday', 'wednesday', 'friday'], template.recurrence_rule['days_of_week']
  end

  test "should create monthly recurring task template with day_of_month" do
    assert_difference 'RecurringTaskTemplate.count', 1 do
      post '/api/v3/recurring-task-templates',
        params: {
          data: {
            type: 'recurring-task-templates',
            attributes: {
              description: 'Monthly report',
              'start-date': '2025-01-15',
              'end-date': '2025-12-31',
              'recurrence-rule': {
                type: 'monthly',
                interval: 1,
                'day-of-month': 15
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :created
    
    template = RecurringTaskTemplate.last
    assert_equal 15, template.recurrence_rule['day_of_month']
    assert_equal Date.parse('2025-12-31'), template.end_date
  end

  test "should create monthly recurring task template with week_of_month" do
    assert_difference 'RecurringTaskTemplate.count', 1 do
      post '/api/v3/recurring-task-templates',
        params: {
          data: {
            type: 'recurring-task-templates',
            attributes: {
              description: 'Board meeting',
              'start-date': '2025-01-01',
              'recurrence-rule': {
                type: 'monthly',
                interval: 1,
                'week-of-month': 'third',
                'day-of-week': 'thursday'
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :created
    
    template = RecurringTaskTemplate.last
    assert_equal 'third', template.recurrence_rule['week_of_month']
    assert_equal 'thursday', template.recurrence_rule['day_of_week']
  end

  test "should validate recurrence rule on create" do
    assert_no_difference 'RecurringTaskTemplate.count' do
      post '/api/v3/recurring-task-templates',
        params: {
          data: {
            type: 'recurring-task-templates',
            attributes: {
              description: 'Invalid task',
              'start-date': '2025-01-01',
              'recurrence-rule': {
                type: 'weekly',
                interval: 0,  # Invalid
                'days-of-week': []  # Invalid
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    
    errors = json['errors']
    assert errors.any? { |e| e['detail'].include?('positive interval') }
    assert errors.any? { |e| e['detail'].include?('days_of_week') }
  end

  # PATCH /api/v3/recurring-task-templates/:id
  test "should update recurring task template" do
    template = create(:recurring_task_template, user: @user, description: "Old description")

    patch "/api/v3/recurring-task-templates/#{template.id}",
      params: {
        data: {
          id: template.id.to_s,
          type: 'recurring-task-templates',
          attributes: {
            description: 'New description',
            'recurrence-rule': {
              type: 'weekly',
              interval: 2,
              'days-of-week': ['tuesday', 'thursday']
            }
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :success
    
    template.reload
    assert_equal 'New description', template.description
    assert_equal 2, template.recurrence_rule['interval']
    assert_equal ['tuesday', 'thursday'], template.recurrence_rule['days_of_week']
  end

  test "should not update other user's template" do
    template = create(:recurring_task_template, user: @other_user)

    patch "/api/v3/recurring-task-templates/#{template.id}",
      params: {
        data: {
          id: template.id.to_s,
          type: 'recurring-task-templates',
          attributes: {
            description: 'Hacked!'
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :not_found
  end

  test "should not allow updating active field directly" do
    template = create(:recurring_task_template, user: @user, active: true)

    patch "/api/v3/recurring-task-templates/#{template.id}",
      params: {
        data: {
          id: template.id.to_s,
          type: 'recurring-task-templates',
          attributes: {
            active: false
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :bad_request  # Field not allowed
    template.reload
    assert template.active?, "Active status should not change"
  end

  # DELETE /api/v3/recurring-task-templates/:id
  test "should soft delete recurring task template" do
    template = create(:recurring_task_template, user: @user, active: true)

    delete "/api/v3/recurring-task-templates/#{template.id}", headers: @headers
    
    assert_response :no_content
    
    template.reload
    assert_not template.active?, "Template should be deactivated"
  end

  test "should not delete other user's template" do
    template = create(:recurring_task_template, user: @other_user)

    delete "/api/v3/recurring-task-templates/#{template.id}", headers: @headers
    
    assert_response :not_found
  end

  # POST /api/v3/recurring-task-templates/:id/deactivate
  test "should deactivate recurring task template" do
    template = create(:recurring_task_template, user: @user, active: true)

    post "/api/v3/recurring-task-templates/#{template.id}/deactivate", headers: @headers
    
    assert_response :success
    
    template.reload
    assert_not template.active?
  end

  # Authentication tests
  test "should require authentication" do
    sign_out @user

    get '/api/v3/recurring-task-templates', headers: @headers
    assert_response :unauthorized

    post '/api/v3/recurring-task-templates', headers: @headers
    assert_response :unauthorized
  end
end
