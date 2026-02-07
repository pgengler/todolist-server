require 'test_helper'

class ListTest < ActiveSupport::TestCase
  test "name must be unique within a list_type" do
    create(:list, name: 'foo', list_type: 'list')
    assert_raises ActiveRecord::RecordInvalid do
      List.create!(name: 'foo', list_type: 'list')
    end
  end

  test "name need not be unique across list_types" do
    create(:list, name: 'Monday', list_type: 'list')
    assert_nothing_raised do
      List.create!(name: 'Monday', list_type: 'recurring-task-day')
    end
  end

  test "name is a required attribute" do
    assert_raises ActiveRecord::RecordInvalid do
      List.create!(name: nil, list_type: 'list')
    end
  end

  test "list_type is a required attribute" do
    assert_raises ActiveRecord::RecordInvalid do
      List.create!(name: 'new list', list_type: nil)
    end
  end

  test "lists cannot be created with invalid list types" do
    assert_raises ActiveRecord::RecordInvalid do
      List.create!(name: 'new list', list_type: 'foobar')
    end
  end

  test "recurring tasks are added to 'day' lists with future dates" do
    tomorrow = 1.day.from_now

    # Create a daily recurrence rule that starts today
    create(:recurrence_rule, :daily, description: 'Daily task', start_date: Date.today)

    list = List.create!(name: tomorrow.strftime('%Y-%m-%d'), list_type: 'day')
    assert list.tasks.count > 0, "recurring tasks were populated"
  end

  test "recurring tasks are not added to days in the past" do
    last_week = 1.week.ago

    # Create a daily recurrence rule
    create(:recurrence_rule, :daily, description: 'Daily task', start_date: 2.weeks.ago)

    list = List.create!(name: last_week.strftime('%Y-%m-%d'), list_type: 'day')
    assert_equal 0, list.tasks.count
  end
end
