Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :items
			resources :days, only: [ :index ]
		end
	end
end
