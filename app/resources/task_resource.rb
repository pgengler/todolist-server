class TaskResource < JSONAPI::Resource
  attributes :description, :done, :due_date, :notes,
             :original_date, :instance_modified, :skipped, :recurring

  def self.sortable_fields(context)
    super(context) + [:due_date, :plaintext_description]
  end

  def recurring
    @model.recurring?
  end

  has_one :list
  has_one :recurrence_rule

  filter :overdue,
    apply: ->(records, values, _options) {
      records.overdue
    }

  filter :due_before,
    apply: ->(records, values, _options) {
      records.due_before(values[0])
    }

  def self.apply_sort(records, order_options, options)
    if order_options.any?
      order_options.each_pair do |field, direction|
        records = case field
        when 'due_date'
          records.by_list_name
        when 'plaintext_description'
          records.by_plaintext_description
        else
          apply_single_sort(records, field, direction, options)
        end
      end
    end

    records
  end
end
