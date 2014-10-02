require 'test_helper'

class RecurringTaskTest < ActiveSupport::TestCase
  test "requires a description" do
    assert_raises ActiveRecord::RecordInvalid do
      RecurringTask.create! day: :monday
    end
  end
end
