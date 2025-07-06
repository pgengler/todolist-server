require 'test_helper'

class RecurringTaskInstanceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @template = create(:recurring_task_template, user: @user)
  end

  # Validation tests
  test "should be valid with valid attributes" do
    instance = build(:recurring_task_instance, recurring_task_template: @template)
    assert instance.valid?
  end

  test "should require scheduled_date" do
    instance = build(:recurring_task_instance, 
      recurring_task_template: @template, 
      scheduled_date: nil
    )
    assert_not instance.valid?
    assert_includes instance.errors[:scheduled_date], "can't be blank"
  end

  test "should validate status inclusion" do
    instance = build(:recurring_task_instance, 
      recurring_task_template: @template,
      status: 'invalid'
    )
    assert_not instance.valid?
    assert_includes instance.errors[:status], "is not included in the list"
  end

  test "should allow valid statuses" do
    %w[pending created skipped deleted].each do |status|
      instance = build(:recurring_task_instance, 
        recurring_task_template: @template,
        status: status
      )
      assert instance.valid?, "Status '#{status}' should be valid"
    end
  end

  # Scope tests
  test "pending scope returns only pending instances" do
    pending = create(:recurring_task_instance, 
      recurring_task_template: @template,
      status: 'pending'
    )
    created = create(:recurring_task_instance,
      recurring_task_template: @template,
      status: 'created'
    )
    
    assert_includes RecurringTaskInstance.pending, pending
    assert_not_includes RecurringTaskInstance.pending, created
  end

  test "created scope returns only created instances" do
    pending = create(:recurring_task_instance,
      recurring_task_template: @template,
      status: 'pending'
    )
    created = create(:recurring_task_instance,
      recurring_task_template: @template,
      status: 'created'
    )
    
    assert_includes RecurringTaskInstance.created, created
    assert_not_includes RecurringTaskInstance.created, pending
  end

  # create_task_for_list tests
  test "create_task_for_list creates task when pending" do
    date = Date.parse('2025-01-15')
    list = create(:list, name: date.to_s, list_type: 'day')
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'pending'
    )
    
    assert_difference 'Task.count', 1 do
      instance.create_task_for_list(list)
    end
    
    instance.reload
    assert_equal 'created', instance.status
    assert_not_nil instance.task
    assert_equal @template.description, instance.task.description
    assert_equal list, instance.task.list
  end

  test "create_task_for_list does nothing when already created" do
    date = Date.parse('2025-01-15')
    list = create(:list, name: date.to_s, list_type: 'day')
    task = create(:task, list: list)
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'created',
      task: task
    )
    
    assert_no_difference 'Task.count' do
      instance.create_task_for_list(list)
    end
  end

  test "create_task_for_list does nothing when skipped" do
    date = Date.parse('2025-01-15')
    list = create(:list, name: date.to_s, list_type: 'day')
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'skipped'
    )
    
    assert_no_difference 'Task.count' do
      instance.create_task_for_list(list)
    end
  end

  test "create_task_for_list uses modified description from override" do
    date = Date.parse('2025-01-15')
    list = create(:list, name: date.to_s, list_type: 'day')
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: date,
      override_type: 'modified',
      override_data: { 'description' => 'Modified description' }
    )
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: date,
      status: 'pending'
    )
    
    instance.create_task_for_list(list)
    
    instance.reload
    assert_equal 'Modified description', instance.task.description
  end

  test "create_task_for_list skips if rescheduled to different date" do
    original_date = Date.parse('2025-01-15')
    new_date = Date.parse('2025-01-16')
    list = create(:list, name: original_date.to_s, list_type: 'day')
    
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: original_date,
      override_type: 'rescheduled',
      override_data: { 'new_date' => new_date.to_s }
    )
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: original_date,
      status: 'pending'
    )
    
    assert_no_difference 'Task.count' do
      instance.create_task_for_list(list)
    end
  end

  test "create_task_for_list creates task on rescheduled date" do
    original_date = Date.parse('2025-01-15')
    new_date = Date.parse('2025-01-16')
    list = create(:list, name: new_date.to_s, list_type: 'day')
    
    override = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: original_date,
      override_type: 'rescheduled',
      override_data: { 'new_date' => new_date.to_s }
    )
    instance = create(:recurring_task_instance,
      recurring_task_template: @template,
      scheduled_date: original_date,
      status: 'pending'
    )
    
    assert_difference 'Task.count', 1 do
      instance.create_task_for_list(list)
    end
  end

  # Association tests
  test "belongs to recurring_task_template" do
    instance = create(:recurring_task_instance, recurring_task_template: @template)
    assert_equal @template, instance.recurring_task_template
  end

  test "optionally belongs to task" do
    instance = create(:recurring_task_instance, recurring_task_template: @template)
    assert_nil instance.task
    
    task = create(:task)
    instance.update!(task: task)
    assert_equal task, instance.task
  end
end
