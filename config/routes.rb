Rails.application.routes.draw do
	scope 'api' do
		scope 'v1' do
			resources :items
			get 'tags' => 'tags#index'
		end
	end
end
