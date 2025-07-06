class List < ApplicationRecord
  acts_as_paranoid column: 'deleted', column_type: 'boolean'

  after_create :populate_recurring_tasks
  before_update :validate_list_updatable, prepend: true
  before_destroy :validate_list_deletable, prepend: true

  has_many :tasks

  VALID_LIST_TYPES = ['day', 'list', 'recurring-task-day']
  CREATABLE_LIST_TYPES = ['list']
  UPDATABLE_LIST_TYPES = ['list']
  DELETABLE_LIST_TYPES = ['list']

  validates :name, presence: true, uniqueness: { scope: :list_type }
  validates :list_type, inclusion: { in: VALID_LIST_TYPES }

  def self.active
    where(deleted: false)
  end

  private

  def populate_recurring_tasks
    return unless list_type == 'day'

    date = Date.parse(name)
    return if date.nil?
    return if date < Date.today

    # First, handle new flexible recurring tasks (v3)
    populate_flexible_recurring_tasks(date)

    # Then, handle legacy weekly recurring tasks (v2) for backward compatibility
    populate_legacy_recurring_tasks(date)
  end

  def populate_flexible_recurring_tasks(date)
    # Find all active recurring task templates that should create tasks for this date
    RecurringTaskTemplate.active.includes(:recurring_task_overrides).find_each do |template|
      next unless template.occurs_on?(date)
      next if template.has_override_for?(date, 'deleted')

      # Check if instance already exists (idempotency)
      instance = RecurringTaskInstance.find_or_create_by(
        recurring_task_template: template,
        scheduled_date: date
      ) do |inst|
        inst.status = 'pending'
      end

      # Create the actual task if instance is pending
      instance.create_task_for_list(self) if instance.pending?
    end
  end

  def populate_legacy_recurring_tasks(date)
    # Keep existing logic for backward compatibility
    recurring_task_list = List.unscoped.find_by(name: date.strftime('%A'), list_type: 'recurring-task-day')
    return if recurring_task_list.nil?
    recurring_task_list.tasks.each do |recurring_task|
      tasks.create!(description: recurring_task.description)
    end
  end

  def validate_list_deletable
    unless DELETABLE_LIST_TYPES.include?(list_type)
      errors.add :base, "Cannot delete '#{list_type}' lists"
    end
    unless tasks.empty?
      errors.add :base, 'Cannot delete a list with tasks'
    end
    throw :abort unless errors.blank?
  end

  def validate_list_updatable
    original_list_type = changed_attributes.has_key?(:list_type) ? changed_attributes[:list_type] : list_type
    unless UPDATABLE_LIST_TYPES.include?(original_list_type)
      errors.add :base, "Cannot update '#{original_list_type}' lists"
    end
    if original_list_type != list_type && !UPDATABLE_LIST_TYPES.include?(list_type)
      errors.add :base, "Cannot change list_type to #{list_type}"
    end
    throw :abort unless errors.blank?
  end
end
