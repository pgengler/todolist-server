class ListResource < JSONAPI::Resource
  attributes :name, :list_type, :sort_order

  has_many :tasks

  filter :list_type
  filter :name
  filter :date,
    verify: ->(values, context) {
      dates = Array(values[0])
      dates.map { |date| List.find_or_create_by(name: date, list_type: 'day') }
    },
    apply: ->(records, values, _options) {
      List.where('id in (?)', values).order(:name)
    }
end
