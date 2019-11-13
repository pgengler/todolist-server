class TaskResource < JSONAPI::Resource
  attributes :description, :done

  has_one :list

  filter :overdue,
    apply: ->(records, values, _options) {
      records.overdue
    }
end
