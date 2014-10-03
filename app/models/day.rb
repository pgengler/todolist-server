class Day < ActiveRecord::Base
	after_create :populate_recurring_tasks
	has_many :tasks

	def self.sliding_window
		days = [ ]
		date = 1.day.ago
		5.times do
			day = where(date: date).first
			unless day
				day = Day.create!(date: date)
			end
			days << day
			date = date + 1.day
		end

		days
	end

	private
	def populate_recurring_tasks
		RecurringTask.where(day: date.wday).each do |recurring_task|
			tasks.create(description: recurring_task.description)
		end
	end
end
