class RecurringTasksController < JSONAPI::ResourceController
	def context
		{ day: params.fetch(:data, {}).fetch(:relationships, {}).fetch(:day, {}).fetch(:data, {}).fetch(:id, nil) }
	end
end
