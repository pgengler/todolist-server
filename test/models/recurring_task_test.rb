require 'test_helper'

class RecurringTaskTest < ActiveSupport::TestCase
  test "requires a description" do
    assert_raises ActiveRecord::RecordInvalid do
      RecurringTask.create! day: :monday
    end
  end

  test "requires a day" do
    assert_raises ActiveRecord::RecordInvalid do
      RecurringTask.create! description: 'Do this once a week'
    end
  end
end
