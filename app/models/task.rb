class Task < ApplicationRecord
  belongs_to :list
  has_and_belongs_to_many :tags

  validates :list_id, presence: true
  validates :description, presence: true

  scope :overdue, -> { joins(:list).where(done: false).where("lists.list_type = 'day' and to_date(lists.name, 'YYYY-MM-DD') < to_date(to_char(now(), 'YYYY-MM-DD'), 'YYYY-MM-DD')") }

  def due_date
    nil unless list.list_type == 'day'
    list.name
  end

  def self.by_list_name
    joins(:list).order('lists.name')
  end

  def self.by_plaintext_description
    order(Arel.sql("REGEXP_REPLACE(description, '[^A-Za-z0-9]', '', 'g')"))
  end
end
