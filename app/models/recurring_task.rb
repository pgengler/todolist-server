class RecurringTask < ApplicationRecord
  enum day: [ :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday ]

  validates :description, presence: true
  validates :day, inclusion: { in: days.keys }

  belongs_to :recurring_task_day
end
