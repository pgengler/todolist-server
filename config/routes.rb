Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :items
			resources :tags, only: [ :index, :update ]
			resources :item_tags, only: [ :index, :create ]
		end
	end
end
