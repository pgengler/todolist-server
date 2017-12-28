class RecurringTaskDayResource < JSONAPI::Resource
  immutable

  attributes :day

  has_many :recurring_tasks

  def self.find(*)
    RecurringTaskDay.all.map { |day| new(day, nil) }
  end
end
