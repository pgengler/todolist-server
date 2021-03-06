class Task < ApplicationRecord
  belongs_to :list
  has_and_belongs_to_many :tags

  validates :list_id, presence: true
  validates :description, presence: true

  scope :overdue, -> { joins(:list).where(done: false).where("lists.list_type = 'day' and to_date(lists.name, 'YYYY-MM-DD') < to_date(to_char(now(), 'YYYY-MM-DD'), 'YYYY-MM-DD')") }
end
