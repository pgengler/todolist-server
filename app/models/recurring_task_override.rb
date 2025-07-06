class RecurringTaskOverride < ApplicationRecord
  belongs_to :recurring_task_template

  validates :original_date, presence: true
  validates :override_type, inclusion: { in: %w[deleted modified rescheduled] }
  
  validate :valid_override_data

  private

  def valid_override_data
    return if override_data.blank?

    case override_type
    when 'modified'
      # Modified can have description changes
      unless override_data.is_a?(Hash)
        errors.add(:override_data, 'must be a hash for modified overrides')
      end
    when 'rescheduled'
      # Rescheduled must have new_date
      unless override_data['new_date'].present?
        errors.add(:override_data, 'must include new_date for rescheduled overrides')
      end
      begin
        Date.parse(override_data['new_date'])
      rescue ArgumentError
        errors.add(:override_data, 'new_date must be a valid date')
      end
    when 'deleted'
      # Deleted doesn't need any data
    end
  end
end
