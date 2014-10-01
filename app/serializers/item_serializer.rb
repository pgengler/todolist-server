class ItemSerializer < ActiveModel::Serializer
	embed :ids, include: true
	attributes :id, :event, :done
end
