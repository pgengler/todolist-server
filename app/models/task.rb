class Task < ApplicationRecord
  belongs_to :day
  belongs_to :list
  has_and_belongs_to_many :tags

  validates :list_id, presence: true
  validates :description, presence: true
end
