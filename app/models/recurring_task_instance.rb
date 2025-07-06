class RecurringTaskInstance < ApplicationRecord
  belongs_to :recurring_task_template
  belongs_to :task, optional: true

  validates :scheduled_date, presence: true
  validates :status, inclusion: { in: %w[pending created skipped deleted] }

  scope :pending, -> { where(status: 'pending') }
  scope :created, -> { where(status: 'created') }

  def create_task_for_list(list)
    return if status != 'pending'
    return unless task.nil?

    override = recurring_task_template.recurring_task_overrides.find_by(
      original_date: scheduled_date,
      override_type: 'rescheduled'
    )

    # Skip if this instance was rescheduled to a different date
    if override && override.override_data['new_date'].present?
      new_date = Date.parse(override.override_data['new_date'])
      return unless list.name == new_date.to_s
    end

    description = recurring_task_template.description_for_date(scheduled_date)
    
    created_task = list.tasks.create!(description: description)
    update!(task: created_task, status: 'created')
  end
end
