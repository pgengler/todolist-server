class DaySerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :date
  has_many :tasks, include: true
end
