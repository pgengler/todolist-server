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
