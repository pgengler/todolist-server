require 'test_helper'

class ListTest < ActiveSupport::TestCase
  test "name must be unique within a list_type" do
    create(:list, name: 'foo', list_type: 'list')
    assert_raises ActiveRecord::RecordInvalid do
      List.create!(name: 'foo', list_type: 'list')
    end
  end

  test "name need not be unique across list_types" do
    create(:list, name: 'foo', list_type: 'list')
    assert_nothing_raised do
      List.create!(name: 'foo', list_type: 'other')
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

  test "recurring tasks are added to 'day' lists with future dates" do
    tomorrow = 1.day.from_now

    recurring_task_list = create(:list, name: tomorrow.strftime('%A'), list_type: 'recurring-task-day')
    create(:task, list_id: recurring_task_list.id)

    list = List.create!(name: tomorrow, list_type: 'day')
    assert list.tasks.count > 0, "recurring tasks were populated"
  end

  test "recurring tasks are not added to days in the past" do
    last_week = 1.week.ago

    recurring_task_list = create(:list, name: last_week.strftime('%A'), list_type: 'recurring-task-day')
    create(:task, list_id: recurring_task_list.id)

    list = List.create!(name: last_week, list_type: 'day')
    assert_equal 0, list.tasks.count
  end
end
