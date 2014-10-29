require 'test_helper'

class DayTest < ActiveSupport::TestCase
	test "window includes five days" do
		assert_equal 5, Day.window.count
	end

	test "sliding window starts one day before the given date" do
		start = Date.new(2014, 1, 1)
		days = Day.window(start)
		assert_equal Date.new(2013, 12, 31), days[0].date
	end
end
