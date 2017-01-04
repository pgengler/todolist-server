class Task < ApplicationRecord
	belongs_to :day
	has_and_belongs_to_many :tags

	validates :day_id, presence: true
end
