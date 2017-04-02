Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :tasks, except: [ :edit, :new ]
			resources :days, only: [ :index, :show ]
			get 'recurring_task_days' => 'recurring_tasks#index'
			resources :recurring_tasks, only: [ :create, :update, :destroy ]
		end
	end
end
