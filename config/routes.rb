Rails.application.routes.draw do
	scope 'api' do
		scope 'v2' do
			jsonapi_resources :lists, only: [ :index ]
			jsonapi_resources :tasks
		end
	end
end
