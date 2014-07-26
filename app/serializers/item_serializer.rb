class ItemSerializer < ActiveModel::Serializer
	attributes :id, :date, :event, :done
	has_many :tags, embed: :id

	def date
		if object.date
			"#{object.date}T23:59:99.999Z"
		else
			nil
		end
	end
end
