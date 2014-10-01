class DaySerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :date
  has_many :items, include: true
end
