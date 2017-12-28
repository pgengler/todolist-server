DAYS = [ :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday ]

class RecurringTaskDay
  attr_reader :id
  attr_reader :day

  def initialize(day)
    @id = day
    @day = day.to_s.titleize
  end

  def recurring_tasks
    RecurringTask.where(day: id)
  end

  def self.all
    DAYS.map { |day| RecurringTaskDay.new(day) }
  end
end
