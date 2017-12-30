class ListResource < JSONAPI::Resource
  attributes :name, :list_type

  has_many :tasks

  filter :list_type
  filter :name
  filter :date,
    verify: ->(values, context) {
      values[0].map { |date| List.find_or_create_by(name: date, list_type: 'day') }
    },
    apply: ->(records, values, _options) {
      List.where('id in (?)', values)
    }
end