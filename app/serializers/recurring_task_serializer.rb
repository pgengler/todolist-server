class RecurringTaskSerializer < ActiveModel::Serializer
  attributes :id, :description, :day_id

	private
	def day_id
		RecurringTask.days[object.day]
	end
end
