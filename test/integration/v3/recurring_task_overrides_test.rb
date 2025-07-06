require 'test_helper'

class V3::RecurringTaskOverridesTest < ActionDispatch::IntegrationTest
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

  # GET /api/v3/recurring-task-overrides
  test "should list user's recurring task overrides" do
    override1 = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'deleted'
    )
    override2 = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-22'),
      override_type: 'modified'
    )
    other_override = create(:recurring_task_override,
      recurring_task_template: @other_template
    )

    get '/api/v3/recurring-task-overrides', headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 2, json['data'].length
    ids = json['data'].map { |o| o['id'] }
    assert_includes ids, override1.id.to_s
    assert_includes ids, override2.id.to_s
    assert_not_includes ids, other_override.id.to_s
  end

  test "should filter by template_id" do
    template2 = create(:recurring_task_template, user: @user)
    override1 = create(:recurring_task_override, recurring_task_template: @template)
    override2 = create(:recurring_task_override, recurring_task_template: template2)

    get "/api/v3/recurring-task-overrides?filter[template_id]=#{@template.id}", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 1, json['data'].length
    assert_equal override1.id.to_s, json['data'][0]['id']
  end

  test "should filter by override_type" do
    deleted = create(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'deleted'
    )
    modified = create(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'modified',
      override_data: { 'description' => 'Modified' }
    )

    get "/api/v3/recurring-task-overrides?filter[override_type]=deleted", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 1, json['data'].length
    assert_equal deleted.id.to_s, json['data'][0]['id']
  end

  # GET /api/v3/recurring-task-overrides/:id
  test "should show recurring task override" do
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'modified',
      override_data: { 'description' => 'Special meeting' }
    )

    get "/api/v3/recurring-task-overrides/#{override.id}", headers: @headers
    
    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal override.id.to_s, json.dig('data', 'id')
    assert_equal '2025-01-15', json.dig('data', 'attributes', 'original-date')
    assert_equal 'modified', json.dig('data', 'attributes', 'override-type')
    assert_equal 'Special meeting', json.dig('data', 'attributes', 'override-data', 'description')
  end

  test "should not show other user's override" do
    override = create(:recurring_task_override, recurring_task_template: @other_template)

    get "/api/v3/recurring-task-overrides/#{override.id}", headers: @headers
    
    assert_response :not_found
  end

  # POST /api/v3/recurring-task-overrides
  test "should create deleted override" do
    assert_difference 'RecurringTaskOverride.count', 1 do
      post '/api/v3/recurring-task-overrides',
        params: {
          data: {
            type: 'recurring-task-overrides',
            attributes: {
              'original-date': '2025-01-15',
              'override-type': 'deleted'
            },
            relationships: {
              'recurring-task-template': {
                data: {
                  type: 'recurring-task-templates',
                  id: @template.id.to_s
                }
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :created
    
    override = RecurringTaskOverride.last
    assert_equal @template, override.recurring_task_template
    assert_equal Date.parse('2025-01-15'), override.original_date
    assert_equal 'deleted', override.override_type
  end

  test "should create modified override" do
    assert_difference 'RecurringTaskOverride.count', 1 do
      post '/api/v3/recurring-task-overrides',
        params: {
          data: {
            type: 'recurring-task-overrides',
            attributes: {
              'original-date': '2025-01-22',
              'override-type': 'modified',
              'override-data': {
                'description': 'Team offsite meeting'
              }
            },
            relationships: {
              'recurring-task-template': {
                data: {
                  type: 'recurring-task-templates',
                  id: @template.id.to_s
                }
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :created
    
    override = RecurringTaskOverride.last
    assert_equal 'modified', override.override_type
    assert_equal 'Team offsite meeting', override.override_data['description']
  end

  test "should create rescheduled override" do
    assert_difference 'RecurringTaskOverride.count', 1 do
      post '/api/v3/recurring-task-overrides',
        params: {
          data: {
            type: 'recurring-task-overrides',
            attributes: {
              'original-date': '2025-01-15',
              'override-type': 'rescheduled',
              'override-data': {
                'new_date': '2025-01-16'
              }
            },
            relationships: {
              'recurring-task-template': {
                data: {
                  type: 'recurring-task-templates',
                  id: @template.id.to_s
                }
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :created
    
    override = RecurringTaskOverride.last
    assert_equal 'rescheduled', override.override_type
    assert_equal '2025-01-16', override.override_data['new_date']
  end

  test "should not create override for other user's template" do
    assert_no_difference 'RecurringTaskOverride.count' do
      post '/api/v3/recurring-task-overrides',
        params: {
          data: {
            type: 'recurring-task-overrides',
            attributes: {
              'original-date': '2025-01-15',
              'override-type': 'deleted'
            },
            relationships: {
              'recurring-task-template': {
                data: {
                  type: 'recurring-task-templates',
                  id: @other_template.id.to_s
                }
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :unprocessable_entity
  end

  test "should not create duplicate override for same date" do
    create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'deleted'
    )

    assert_no_difference 'RecurringTaskOverride.count' do
      post '/api/v3/recurring-task-overrides',
        params: {
          data: {
            type: 'recurring-task-overrides',
            attributes: {
              'original-date': '2025-01-15',
              'override-type': 'modified',
              'override-data': { 'description': 'Different' }
            },
            relationships: {
              'recurring-task-template': {
                data: {
                  type: 'recurring-task-templates',
                  id: @template.id.to_s
                }
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :unprocessable_entity
  end

  test "should validate rescheduled override data" do
    assert_no_difference 'RecurringTaskOverride.count' do
      post '/api/v3/recurring-task-overrides',
        params: {
          data: {
            type: 'recurring-task-overrides',
            attributes: {
              'original-date': '2025-01-15',
              'override-type': 'rescheduled',
              'override-data': {
                'new_date': 'invalid-date'
              }
            },
            relationships: {
              'recurring-task-template': {
                data: {
                  type: 'recurring-task-templates',
                  id: @template.id.to_s
                }
              }
            }
          }
        }.to_json,
        headers: @headers
    end
    
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json['errors'].any? { |e| e['detail'].include?('valid date') }
  end

  # PATCH /api/v3/recurring-task-overrides/:id
  test "should update override_data" do
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'modified',
      override_data: { 'description' => 'Original' }
    )

    patch "/api/v3/recurring-task-overrides/#{override.id}",
      params: {
        data: {
          id: override.id.to_s,
          type: 'recurring-task-overrides',
          attributes: {
            'override-data': {
              'description': 'Updated description'
            }
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :success
    
    override.reload
    assert_equal 'Updated description', override.override_data['description']
  end

  test "should not allow changing override_type" do
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'deleted'
    )

    patch "/api/v3/recurring-task-overrides/#{override.id}",
      params: {
        data: {
          id: override.id.to_s,
          type: 'recurring-task-overrides',
          attributes: {
            'override-type': 'modified'
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :bad_request  # Field not allowed
    override.reload
    assert_equal 'deleted', override.override_type
  end

  test "should not allow changing original_date" do
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-15')
    )

    patch "/api/v3/recurring-task-overrides/#{override.id}",
      params: {
        data: {
          id: override.id.to_s,
          type: 'recurring-task-overrides',
          attributes: {
            'original-date': '2025-01-16'
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :bad_request  # Field not allowed
    override.reload
    assert_equal Date.parse('2025-01-15'), override.original_date
  end

  test "should not update other user's override" do
    override = create(:recurring_task_override, recurring_task_template: @other_template)

    patch "/api/v3/recurring-task-overrides/#{override.id}",
      params: {
        data: {
          id: override.id.to_s,
          type: 'recurring-task-overrides',
          attributes: {
            'override-data': { 'description': 'Hacked!' }
          }
        }
      }.to_json,
      headers: @headers
    
    assert_response :not_found
  end

  # DELETE /api/v3/recurring-task-overrides/:id
  test "should delete override" do
    override = create(:recurring_task_override, recurring_task_template: @template)

    assert_difference 'RecurringTaskOverride.count', -1 do
      delete "/api/v3/recurring-task-overrides/#{override.id}", headers: @headers
    end
    
    assert_response :no_content
  end

  test "should not delete other user's override" do
    override = create(:recurring_task_override, recurring_task_template: @other_template)

    assert_no_difference 'RecurringTaskOverride.count' do
      delete "/api/v3/recurring-task-overrides/#{override.id}", headers: @headers
    end
    
    assert_response :not_found
  end

  # Authentication tests
  test "should require authentication" do
    sign_out @user

    get '/api/v3/recurring-task-overrides', headers: @headers
    assert_response :unauthorized

    post '/api/v3/recurring-task-overrides', headers: @headers
    assert_response :unauthorized
  end
end
