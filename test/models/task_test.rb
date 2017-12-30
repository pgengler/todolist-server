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
end
