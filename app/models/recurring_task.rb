class RecurringTask < ActiveRecord::Base
  enum day: [ :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday ]

  validates :description, presence: true
  validates :day, presence: true

  def as_json(options={})
    { id: id, description: description, day_id: RecurringTask.days[day] }
  end
end
