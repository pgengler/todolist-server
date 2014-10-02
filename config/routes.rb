Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :tasks
			resources :days, only: [ :index ]
			get 'recurring_task_days' => 'recurring_tasks#index'
			resources :recurring_tasks, only: [ :update ]
		end
	end
end
