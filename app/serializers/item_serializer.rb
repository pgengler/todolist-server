class ItemSerializer < ActiveModel::Serializer
  attributes :id, :date, :event, :location, :start, :end, :done
end
