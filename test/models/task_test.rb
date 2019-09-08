require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  test "requires a 'list_id'" do
    assert_raises ActiveRecord::RecordInvalid do
      Task.create! description: 'Something'
    end
  end

  test "requires a description" do
    assert_raises ActiveRecord::RecordInvalid do
      Task.create! list_id: 1
    end
  end

  test '.overdue returns list of overdue tasks' do
    past_lists = [
      create(:list, name: 1.month.ago, list_type: :day),
      create(:list, name: 2.weeks.ago, list_type: :day),
      create(:list, name: 3.days.ago, list_type: :day)
    ]
    other_lists = [
      create(:list, name: Time.current, list_type: :day),
      create(:list, name: 1.day.from_now, list_type: :day),
      create(:list, name: 1.month.from_now, list_type: :day)
    ]

    overdue_tasks = past_lists.map { |l| create(:task, list: l, done: false) }
    past_lists.each { |l| create(:task, list: l, done: true )}
    other_lists.each do |l|
      create(:task, list: l, done: false)
      create(:task, list: l, done: true)
    end

    assert_equal Task.overdue, overdue_tasks
  end
end
