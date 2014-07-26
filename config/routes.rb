Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :items
			resources :tags, only: [ :index, :update ]
		end
	end
end
