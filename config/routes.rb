Rails.application.routes.draw do
    scope 'api' do
        resources :items
    end
end
