class ItemTagSerializer < ActiveModel::Serializer
	embed :ids, include: true
	attributes :id, :item_id, :tag_id, :position
	has_one :tag
	has_one :item
end