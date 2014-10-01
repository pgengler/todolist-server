class TaskSerializer < ActiveModel::Serializer
	embed :ids, include: true
	attributes :id, :description, :done
end
