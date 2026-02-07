class Task < ApplicationRecord
  belongs_to :list
  belongs_to :recurrence_rule, optional: true
  has_and_belongs_to_many :tags

  validates :list_id, presence: true
  validates :description, presence: true

  scope :overdue, -> { joins(:list).where(done: false).where("lists.list_type = 'day' and to_date(lists.name, 'YYYY-MM-DD') < to_date(to_char(now(), 'YYYY-MM-DD'), 'YYYY-MM-DD')") }
  scope :active, -> { where(skipped: [false, nil]) }
  scope :not_modified, -> { where(instance_modified: [false, nil]) }

  def due_date
    return nil unless list.list_type == 'day'
    list.name
  end

  def recurring?
    recurrence_rule_id.present?
  end

  def skip!
    update!(skipped: true, instance_modified: true)
  end

  def modify_instance!(attributes)
    update!(attributes.merge(instance_modified: true))
  end

  def update_this_and_future!(attributes)
    return unless recurrence_rule

    task_attributes = attributes.slice(:description, :notes)
    rule_attributes = attributes.slice(:description, :notes)

    recurrence_rule.update!(rule_attributes) if rule_attributes.present?

    if task_attributes.present? && original_date
      recurrence_rule.tasks
        .where('original_date >= ?', original_date)
        .not_modified
        .update_all(task_attributes)
    end
  end

  def delete_this_and_future!
    return unless recurrence_rule && original_date

    yesterday = original_date - 1.day
    recurrence_rule.update!(end_date: yesterday)

    recurrence_rule.tasks
      .where('original_date >= ?', original_date)
      .destroy_all
  end

  def self.by_list_name
    joins(:list).order('lists.name')
  end

  def self.by_plaintext_description
    order(Arel.sql("REGEXP_REPLACE(description, '[^A-Za-z0-9]', '', 'g')"))
  end

  def self.due_before(date)
    joins(:list).where(done: false).where("lists.list_type = 'day' and to_date(lists.name, 'YYYY-MM-DD') < to_date(?, 'YYYY-MM-DD')", date)
  end
end
