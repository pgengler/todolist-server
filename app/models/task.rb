class Task < ActiveRecord::Base
  belongs_to :day

  validates :day_id, presence: true
end
