class TagSerializer < ActiveModel::Serializer
	attributes :id, :name
	has_many :items, embed: :id
end
