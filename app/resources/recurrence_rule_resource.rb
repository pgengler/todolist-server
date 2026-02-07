class RecurrenceRuleResource < JSONAPI::Resource
  attributes :description, :notes, :recurrence_type,
             :interval, :day_of_week, :days_of_week,
             :day_of_month, :week_of_month, :month,
             :anchor_date, :start_date, :end_date,
             :max_instances, :instances_created, :human_readable_schedule

  has_many :tasks

  def human_readable_schedule
    @model.human_readable_schedule
  end
end
