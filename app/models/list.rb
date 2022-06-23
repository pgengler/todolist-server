class List < ApplicationRecord
  after_create :populate_recurring_tasks

  has_many :tasks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :list_type }
  validates :list_type, presence: true

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
end
