class RecurringTaskResource < JSONAPI::Resource
  has_one :recurring_task_day

  attributes :day, :description

  before_save do
    @model.day = context[:day]
  end
end
