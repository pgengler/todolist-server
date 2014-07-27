class TagSerializer < ActiveModel::Serializer
	embed :ids, include: true
	attributes :id, :name
	has_many :item_tags
	has_many :items
end
