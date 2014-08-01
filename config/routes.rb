Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :items
			resources :tags, only: [ :create, :index, :update ]
			resources :item_tags, only: [ :create, :index, :show ]
		end
	end
end
