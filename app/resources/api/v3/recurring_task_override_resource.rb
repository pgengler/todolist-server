module Api
  module V3
    class RecurringTaskOverrideResource < JSONAPI::Resource
      attributes :original_date, :override_type, :override_data
      
      has_one :recurring_task_template

      filter :original_date
      filter :override_type

      def self.records(options = {})
        context = options[:context]
        RecurringTaskOverride.joins(:recurring_task_template)
                            .where(recurring_task_templates: { user_id: context[:current_user].id })
      end

      def self.creatable_fields(context)
        super
      end

      def self.updatable_fields(context)
        [:override_data]  # Only allow updating the override data
      end
    end
  end
end
