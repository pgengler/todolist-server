require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "requires a 'day_id'" do
    assert_raises ActiveRecord::RecordInvalid do
      Item.create! event: 'Something'
    end
  end
end
