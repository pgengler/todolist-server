Rails.application.routes.draw do
	scope 'api' do
		scope 'v2' do
			jsonapi_resources :recurring_task_days, only: :index
			jsonapi_resources :recurring_tasks, only: [ :create, :update, :destroy ]
			jsonapi_resources :days, only: [ :index, :show ]
			jsonapi_resources :tasks
		end
	end
end
