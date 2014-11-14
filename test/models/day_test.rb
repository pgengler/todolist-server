require 'test_helper'

class DayTest < ActiveSupport::TestCase
	test "recurring tasks are added to days in the future" do
		tomorrow = 1.day.from_now
		RecurringTask.create!(day: tomorrow.wday, description: 'A recurring task for tomorrow')

		day = Day.create!(date: tomorrow)
		assert day.tasks.count > 0, "no recurring tasks were populated"
	end

	test "recurring tasks are not added to days in the past" do
		yesterday = 1.day.ago
		RecurringTask.create!(day: yesterday.wday, description: 'A recurring task for yesterday')

		day = Day.create!(date: yesterday)
		assert_equal 0, day.tasks.count
	end
end
