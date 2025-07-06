module Api
  module V3
    class RecurringTaskTemplateResource < JSONAPI::Resource
      attributes :description, :recurrence_rule, :start_date, :end_date, :active
      
      has_many :recurring_task_instances
      has_many :recurring_task_overrides

      filter :active, default: true

      def self.records(options = {})
        context = options[:context]
        context[:current_user].recurring_task_templates
      end

      def self.creatable_fields(context)
        super - [:active]
      end

      def self.updatable_fields(context)
        super - [:active]
      end

      # Custom endpoint to deactivate (soft delete)
      def deactivate
        @model.update!(active: false)
      end
    end
  end
end
