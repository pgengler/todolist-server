require 'test_helper'

class RecurringTaskTemplateTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  # Validation tests
  test "should be valid with valid attributes" do
    template = build(:recurring_task_template, user: @user)
    assert template.valid?
  end

  test "should require description" do
    template = build(:recurring_task_template, user: @user, description: nil)
    assert_not template.valid?
    assert_includes template.errors[:description], "can't be blank"
  end

  test "should require recurrence_rule" do
    template = build(:recurring_task_template, user: @user, recurrence_rule: nil)
    assert_not template.valid?
    assert_includes template.errors[:recurrence_rule], "can't be blank"
  end

  test "should require start_date" do
    template = build(:recurring_task_template, user: @user, start_date: nil)
    assert_not template.valid?
    assert_includes template.errors[:start_date], "can't be blank"
  end

  test "should validate weekly recurrence rule" do
    template = build(:recurring_task_template, user: @user, recurrence_rule: {
      type: 'weekly',
      interval: 0,
      days_of_week: []
    })
    assert_not template.valid?
    assert_includes template.errors[:recurrence_rule], "weekly rule must have a positive interval"
    assert_includes template.errors[:recurrence_rule], "weekly rule must specify days_of_week"
  end

  test "should validate monthly recurrence rule with day_of_month" do
    template = build(:recurring_task_template, user: @user, recurrence_rule: {
      type: 'monthly',
      interval: 1,
      day_of_month: 32
    })
    assert_not template.valid?
    assert_includes template.errors[:recurrence_rule], "day_of_month must be between 1 and 31"
  end

  test "should validate monthly recurrence rule with week_of_month" do
    template = build(:recurring_task_template, user: @user, recurrence_rule: {
      type: 'monthly',
      interval: 1,
      week_of_month: 'invalid',
      day_of_week: 'monday'
    })
    assert_not template.valid?
    assert_includes template.errors[:recurrence_rule], "week_of_month must be one of: first, second, third, fourth, last"
  end

  # occurs_on? tests for weekly recurrence
  test "occurs_on? returns true for weekly recurrence on matching day" do
    template = create(:recurring_task_template, 
      user: @user,
      start_date: Date.parse('2025-01-06'), # Monday
      recurrence_rule: {
        type: 'weekly',
        interval: 1,
        days_of_week: ['monday', 'wednesday', 'friday']
      }
    )
    
    assert template.occurs_on?(Date.parse('2025-01-06')) # Monday
    assert template.occurs_on?(Date.parse('2025-01-08')) # Wednesday
    assert template.occurs_on?(Date.parse('2025-01-10')) # Friday
    assert_not template.occurs_on?(Date.parse('2025-01-07')) # Tuesday
  end

  test "occurs_on? handles bi-weekly recurrence" do
    template = create(:recurring_task_template,
      user: @user,
      start_date: Date.parse('2025-01-06'), # Monday
      recurrence_rule: {
        type: 'weekly',
        interval: 2,
        days_of_week: ['monday']
      }
    )
    
    assert template.occurs_on?(Date.parse('2025-01-06')) # Week 0
    assert_not template.occurs_on?(Date.parse('2025-01-13')) # Week 1
    assert template.occurs_on?(Date.parse('2025-01-20')) # Week 2
  end

  test "occurs_on? returns false before start_date" do
    template = create(:recurring_task_template,
      user: @user,
      start_date: Date.parse('2025-01-10'),
      recurrence_rule: {
        type: 'weekly',
        interval: 1,
        days_of_week: ['friday']
      }
    )
    
    assert_not template.occurs_on?(Date.parse('2025-01-03')) # Friday before start
  end

  test "occurs_on? returns false after end_date" do
    template = create(:recurring_task_template,
      user: @user,
      start_date: Date.parse('2025-01-01'),
      end_date: Date.parse('2025-01-31'),
      recurrence_rule: {
        type: 'weekly',
        interval: 1,
        days_of_week: ['friday']
      }
    )
    
    assert_not template.occurs_on?(Date.parse('2025-02-07')) # Friday after end
  end

  # occurs_on? tests for monthly recurrence
  test "occurs_on? returns true for monthly recurrence on specific date" do
    template = create(:recurring_task_template,
      user: @user,
      start_date: Date.parse('2025-01-15'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        day_of_month: 15
      }
    )
    
    assert template.occurs_on?(Date.parse('2025-01-15'))
    assert template.occurs_on?(Date.parse('2025-02-15'))
    assert_not template.occurs_on?(Date.parse('2025-01-16'))
  end

  test "occurs_on? handles quarterly recurrence" do
    template = create(:recurring_task_template,
      user: @user,
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 3,
        day_of_month: 1
      }
    )
    
    assert template.occurs_on?(Date.parse('2025-01-01'))
    assert_not template.occurs_on?(Date.parse('2025-02-01'))
    assert_not template.occurs_on?(Date.parse('2025-03-01'))
    assert template.occurs_on?(Date.parse('2025-04-01'))
  end

  test "occurs_on? returns true for third Thursday of month" do
    template = create(:recurring_task_template,
      user: @user,
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        week_of_month: 'third',
        day_of_week: 'thursday'
      }
    )
    
    assert template.occurs_on?(Date.parse('2025-01-16')) # 3rd Thursday
    assert_not template.occurs_on?(Date.parse('2025-01-09')) # 2nd Thursday
    assert_not template.occurs_on?(Date.parse('2025-01-23')) # 4th Thursday
  end

  test "occurs_on? returns true for last Friday of month" do
    template = create(:recurring_task_template,
      user: @user,
      start_date: Date.parse('2025-01-01'),
      recurrence_rule: {
        type: 'monthly',
        interval: 1,
        week_of_month: 'last',
        day_of_week: 'friday'
      }
    )
    
    assert template.occurs_on?(Date.parse('2025-01-31')) # Last Friday of Jan
    assert_not template.occurs_on?(Date.parse('2025-01-24')) # Not last Friday
  end

  # Override tests
  test "has_override_for? returns true when override exists" do
    template = create(:recurring_task_template, user: @user)
    override = create(:recurring_task_override,
      recurring_task_template: template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'deleted'
    )
    
    assert template.has_override_for?(Date.parse('2025-01-15'))
    assert template.has_override_for?(Date.parse('2025-01-15'), 'deleted')
    assert_not template.has_override_for?(Date.parse('2025-01-15'), 'modified')
  end

  test "description_for_date returns overridden description" do
    template = create(:recurring_task_template, 
      user: @user,
      description: "Original task"
    )
    override = create(:recurring_task_override,
      recurring_task_template: template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'modified',
      override_data: { 'description' => 'Modified task' }
    )
    
    assert_equal 'Modified task', template.description_for_date(Date.parse('2025-01-15'))
    assert_equal 'Original task', template.description_for_date(Date.parse('2025-01-16'))
  end

  # Association tests
  test "should have many recurring_task_instances" do
    template = create(:recurring_task_template, user: @user)
    instance1 = create(:recurring_task_instance, 
      recurring_task_template: template,
      scheduled_date: Date.parse('2025-01-15')
    )
    instance2 = create(:recurring_task_instance,
      recurring_task_template: template,
      scheduled_date: Date.parse('2025-01-22')
    )
    
    assert_equal 2, template.recurring_task_instances.count
    assert_includes template.recurring_task_instances, instance1
    assert_includes template.recurring_task_instances, instance2
  end

  test "should destroy associated instances when destroyed" do
    template = create(:recurring_task_template, user: @user)
    instance = create(:recurring_task_instance, recurring_task_template: template)
    
    assert_difference 'RecurringTaskInstance.count', -1 do
      template.destroy
    end
  end
end
