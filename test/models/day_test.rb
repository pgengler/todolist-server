require 'test_helper'

class DayTest < ActiveSupport::TestCase
  test "sliding window includes five days" do
    assert_equal 5, Day.sliding_window.count
  end
end
