Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :tasks
			resources :days, only: [ :index ]
		end
	end
end
