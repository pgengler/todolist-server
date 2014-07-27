class ItemSerializer < ActiveModel::Serializer
	embed :ids
	attributes :id, :date, :event, :done
	has_many :item_tags

	def date
		if object.date
			"#{object.date}T23:59:99.999Z"
		else
			nil
		end
	end
end
