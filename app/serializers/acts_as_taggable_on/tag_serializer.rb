module ActsAsTaggableOn
	class TagSerializer < ActiveModel::Serializer
		attributes :id, :name, :items
		has_many :items, embed: :id

		def items
			object.taggings.all.map do |tagging|
				tagging.taggable
			end
		end
	end
end