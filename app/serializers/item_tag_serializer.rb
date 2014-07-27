class ItemTagSerializer < ActiveModel::Serializer
	attributes :id, :item_id, :tag_id
end