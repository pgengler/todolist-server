require 'test_helper'

class ListPopulateRecurringTasksTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "populate_recurring_tasks creates tasks from v2 weekly recurring tasks" do
    day_name = 'Monday'
    date = Date.parse('2025-01-13') # A Monday
    
    recurring_task_day = create(:recurring_task_day, name: day_name, user: @user)
    recurring_task1 = create(:recurring_task, 
      description: "V2 Task 1",
      day: 'monday',
      recurring_task_day: recurring_task_day
    )
    recurring_task2 = create(:recurring_task,
      description: "V2 Task 2", 
      day: 'monday',
      recurring_task_day: recurring_task_day
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    assert_difference 'Task.count', 2 do
      list.populate_recurring_tasks
    end
    
    tasks = list.tasks.where(description: ["V2 Task 1", "V2 Task 2"])
    assert_equal 2, tasks.count
  end

  test "populate_recurring_tasks creates tasks from v3 flexible recurring tasks" do
    date = Date.parse('2025-01-15') # A Wednesday
    
    # Weekly template that occurs on Wednesday
    template1 = create(:recurring_task_template,
      user: @user,
      description: "V3 Weekly Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'weekly',
        interval: 1,
        days_of_week: ['monday', 'wednesday', 'friday']
      }
    )
    
    # Monthly template that occurs on the 15th
    template2 = create(:recurring_task_template,
      user: @user,
      description: "V3 Monthly Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )
    
    # Template that doesn't occur on this date
    template3 = create(:recurring_task_template,
      user: @user,
      description: "V3 Non-matching Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'weekly',
        interval: 1,
        days_of_week: ['tuesday', 'thursday']
      }
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    assert_difference 'Task.count', 2 do
      assert_difference 'RecurringTaskInstance.count', 2 do
        list.populate_recurring_tasks
      end
    end
    
    tasks = list.tasks.where(description: ["V3 Weekly Task", "V3 Monthly Task"])
    assert_equal 2, tasks.count
    
    # Verify instances were created
    instance1 = RecurringTaskInstance.find_by(
      recurring_task_template: template1,
      scheduled_date: date
    )
    assert_not_nil instance1
    assert_equal 'created', instance1.status
    assert_includes tasks, instance1.task
    
    instance2 = RecurringTaskInstance.find_by(
      recurring_task_template: template2,
      scheduled_date: date
    )
    assert_not_nil instance2
    assert_equal 'created', instance2.status
    assert_includes tasks, instance2.task
    
    # Verify non-matching template didn't create instance
    instance3 = RecurringTaskInstance.find_by(
      recurring_task_template: template3,
      scheduled_date: date
    )
    assert_nil instance3
  end

  test "populate_recurring_tasks handles both v2 and v3 tasks together" do
    date = Date.parse('2025-01-13') # A Monday
    
    # V2 recurring task
    recurring_task_day = create(:recurring_task_day, name: 'Monday', user: @user)
    recurring_task = create(:recurring_task,
      description: "V2 Monday Task",
      day: 'monday',
      recurring_task_day: recurring_task_day
    )
    
    # V3 recurring task template
    template = create(:recurring_task_template,
      user: @user,
      description: "V3 Monday Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'weekly',
        interval: 1,
        days_of_week: ['monday']
      }
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    assert_difference 'Task.count', 2 do
      list.populate_recurring_tasks
    end
    
    descriptions = list.tasks.pluck(:description).sort
    assert_equal ["V2 Monday Task", "V3 Monday Task"], descriptions
  end

  test "populate_recurring_tasks respects v3 template active status" do
    date = Date.parse('2025-01-15')
    
    active_template = create(:recurring_task_template,
      user: @user,
      description: "Active Task",
      active: true,
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )
    
    inactive_template = create(:recurring_task_template,
      user: @user,
      description: "Inactive Task",
      active: false,
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    assert_difference 'Task.count', 1 do
      list.populate_recurring_tasks
    end
    
    assert_equal ["Active Task"], list.tasks.pluck(:description)
  end

  test "populate_recurring_tasks respects v3 deleted override" do
    date = Date.parse('2025-01-15')
    
    template = create(:recurring_task_template,
      user: @user,
      description: "Deleted Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )
    
    override = create(:recurring_task_override,
      recurring_task_template: template,
      original_date: date,
      override_type: 'deleted'
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    assert_no_difference 'Task.count' do
      list.populate_recurring_tasks
    end
    
    # Instance should be created but marked as deleted
    instance = RecurringTaskInstance.find_by(
      recurring_task_template: template,
      scheduled_date: date
    )
    assert_not_nil instance
    assert_equal 'deleted', instance.status
  end

  test "populate_recurring_tasks uses modified description from override" do
    date = Date.parse('2025-01-15')
    
    template = create(:recurring_task_template,
      user: @user,
      description: "Original Description",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )
    
    override = create(:recurring_task_override,
      recurring_task_template: template,
      original_date: date,
      override_type: 'modified',
      override_data: { 'description' => 'Modified Description' }
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    assert_difference 'Task.count', 1 do
      list.populate_recurring_tasks
    end
    
    task = list.tasks.first
    assert_equal 'Modified Description', task.description
  end

  test "populate_recurring_tasks handles rescheduled tasks" do
    original_date = Date.parse('2025-01-15')
    new_date = Date.parse('2025-01-16')
    
    template = create(:recurring_task_template,
      user: @user,
      description: "Rescheduled Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )
    
    override = create(:recurring_task_override,
      recurring_task_template: template,
      original_date: original_date,
      override_type: 'rescheduled',
      override_data: { 'new_date' => new_date.to_s }
    )

    # List for original date - should not create task
    original_list = create(:list, name: original_date.to_s, list_type: 'day', user: @user)
    
    assert_no_difference 'Task.count' do
      original_list.populate_recurring_tasks
    end
    
    # List for new date - should create task
    new_list = create(:list, name: new_date.to_s, list_type: 'day', user: @user)
    
    assert_difference 'Task.count', 1 do
      new_list.populate_recurring_tasks
    end
    
    task = new_list.tasks.first
    assert_equal 'Rescheduled Task', task.description
  end

  test "populate_recurring_tasks is idempotent" do
    date = Date.parse('2025-01-15')
    
    template = create(:recurring_task_template,
      user: @user,
      description: "Idempotent Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    # First call creates task
    assert_difference 'Task.count', 1 do
      assert_difference 'RecurringTaskInstance.count', 1 do
        list.populate_recurring_tasks
      end
    end
    
    # Second call does nothing
    assert_no_difference 'Task.count' do
      assert_no_difference 'RecurringTaskInstance.count' do
        list.populate_recurring_tasks
      end
    end
  end

  test "populate_recurring_tasks only processes templates for the list owner" do
    date = Date.parse('2025-01-15')
    other_user = create(:user)
    
    my_template = create(:recurring_task_template,
      user: @user,
      description: "My Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )
    
    other_template = create(:recurring_task_template,
      user: other_user,
      description: "Other User Task",
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )

    list = create(:list, name: date.to_s, list_type: 'day', user: @user)
    
    assert_difference 'Task.count', 1 do
      list.populate_recurring_tasks
    end
    
    assert_equal ["My Task"], list.tasks.pluck(:description)
  end
end
