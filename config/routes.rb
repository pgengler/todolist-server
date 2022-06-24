Rails.application.routes.draw do
  scope 'api' do
    devise_for :users
    use_doorkeeper

    scope 'v2' do
      jsonapi_resources :lists, only: [ :index, :destroy ]
      jsonapi_resources :tasks
    end
  end
end
