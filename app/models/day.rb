class Day < ActiveRecord::Base
	after_create :populate_recurring_tasks
	has_many :tasks

	private
	def populate_recurring_tasks
		return if date < Date.today
		RecurringTask.where(day: date.wday).each do |recurring_task|
			tasks.create(description: recurring_task.description)
		end
	end
end
