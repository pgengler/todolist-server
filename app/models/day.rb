class Day < ActiveRecord::Base
  has_many :items

  def self.sliding_window
    days = [ ]
    date = 1.day.ago
    5.times do
      day = where(date: date).first
      unless day
        day = Day.create!(date: date)
      end
      days << day
      date = date + 1.day
    end

    days
  end
end
