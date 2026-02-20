module Api
  module V3
    class RecurringTaskInstanceResource < JSONAPI::Resource
      attributes :scheduled_date, :status
      
      has_one :recurring_task_template
      has_one :task

      filters :scheduled_date, :status
      filter :start_date
      filter :end_date
      filter :template_id

      def self.apply_filter(records, filter, value, options)
        case filter
        when :start_date
          records.where('scheduled_date >= ?', value)
        when :end_date
          records.where('scheduled_date <= ?', value)
        when :template_id
          records.where(recurring_task_template_id: value)
        else
          super
        end
      end

      def self.records(options = {})
        context = options[:context]
        RecurringTaskInstance.joins(:recurring_task_template)
                            .where(recurring_task_templates: { user_id: context[:current_user].id })
      end

      # Custom action to create task from instance
      def create_task
        list = List.find_by!(name: @model.scheduled_date.to_s, list_type: 'day')
        @model.create_task_for_list(list)
      end

      # Custom action to skip this instance
      def skip
        @model.update!(status: 'skipped') if @model.pending?
      end
    end
  end
end
