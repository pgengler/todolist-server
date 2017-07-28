class DayResource < JSONAPI::Resource
  attributes :date

  has_many :tasks

  filter :date,
    verify: ->(values, context) {
      values[0].map { |date| Day.find_or_create_by(date: date) }
    },
    apply: ->(records, values, _options) {
      Day.where('id in (?)', values)
    }
  # filter :start_date, apply: ->(records, values, _options) {
  #   records.where('date >= ?', values[0])
  # }
  #
  # filter :end_date, apply: ->(records, values, _options) {
  #   records.where('date <= ?', values[0])
  # }
end
