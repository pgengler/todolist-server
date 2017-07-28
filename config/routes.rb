Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			get 'recurring_task_days' => 'recurring_tasks#index'
			resources :recurring_tasks, only: [ :create, :update, :destroy ]
		end

		scope 'v2' do
			jsonapi_resources :days, only: [ :index, :show ]
			jsonapi_resources :tasks
		end
	end
end
