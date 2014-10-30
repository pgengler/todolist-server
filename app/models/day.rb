class Day < ActiveRecord::Base
	after_create :populate_recurring_tasks
	has_many :tasks

	def self.window(base=Date.today)
		days = [ ]
		date = base - 1.day
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
		return if date < Date.today
		RecurringTask.where(day: date.wday).each do |recurring_task|
			tasks.create(description: recurring_task.description)
		end
	end
end
