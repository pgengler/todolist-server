require 'test_helper'

class RecurringTaskOverrideTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @template = create(:recurring_task_template, user: @user)
  end

  # Validation tests
  test "should be valid with valid attributes" do
    override = build(:recurring_task_override, recurring_task_template: @template)
    assert override.valid?
  end

  test "should require original_date" do
    override = build(:recurring_task_override, 
      recurring_task_template: @template,
      original_date: nil
    )
    assert_not override.valid?
    assert_includes override.errors[:original_date], "can't be blank"
  end

  test "should validate override_type inclusion" do
    override = build(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'invalid'
    )
    assert_not override.valid?
    assert_includes override.errors[:override_type], "is not included in the list"
  end

  test "should allow valid override types" do
    %w[deleted modified rescheduled].each do |type|
      override = build(:recurring_task_override,
        recurring_task_template: @template,
        override_type: type
      )
      assert override.valid?, "Override type '#{type}' should be valid"
    end
  end

  # Override data validation tests
  test "modified override should accept description in override_data" do
    override = build(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'modified',
      override_data: { 'description' => 'Updated description' }
    )
    assert override.valid?
  end

  test "modified override should validate override_data is hash" do
    override = build(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'modified',
      override_data: 'not a hash'
    )
    assert_not override.valid?
    assert_includes override.errors[:override_data], 'must be a hash for modified overrides'
  end

  test "rescheduled override requires new_date" do
    override = build(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'rescheduled',
      override_data: {}
    )
    assert_not override.valid?
    assert_includes override.errors[:override_data], 'must include new_date for rescheduled overrides'
  end

  test "rescheduled override validates new_date format" do
    override = build(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'rescheduled',
      override_data: { 'new_date' => 'invalid-date' }
    )
    assert_not override.valid?
    assert_includes override.errors[:override_data], 'new_date must be a valid date'
  end

  test "rescheduled override accepts valid date" do
    override = build(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'rescheduled',
      override_data: { 'new_date' => '2025-01-20' }
    )
    assert override.valid?
  end

  test "deleted override doesn't require override_data" do
    override = build(:recurring_task_override,
      recurring_task_template: @template,
      override_type: 'deleted',
      override_data: {}
    )
    assert override.valid?
  end

  # Association tests
  test "belongs to recurring_task_template" do
    override = create(:recurring_task_override, recurring_task_template: @template)
    assert_equal @template, override.recurring_task_template
  end

  # Uniqueness test
  test "should not allow duplicate overrides for same template and date" do
    create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'deleted'
    )
    
    duplicate = build(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'modified'
    )
    
    assert_not duplicate.valid?
  end

  test "should allow same date override for different templates" do
    template2 = create(:recurring_task_template, user: @user)
    
    override1 = create(:recurring_task_override,
      recurring_task_template: @template,
      original_date: Date.parse('2025-01-15'),
      override_type: 'deleted'
    )
    
    override2 = build(:recurring_task_override,
      recurring_task_template: template2,
      original_date: Date.parse('2025-01-15'),
      override_type: 'deleted'
    )
    
    assert override2.valid?
  end
end
