class TaskResource < JSONAPI::Resource
  attributes :description, :done

  has_one :list
end
