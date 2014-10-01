class ItemSerializer < ActiveModel::Serializer
	embed :ids, include: true
	attributes :id, :date, :event, :done

	def date
		if object.date
			"#{object.date}T23:59:99.999Z"
		else
			nil
		end
	end
end
