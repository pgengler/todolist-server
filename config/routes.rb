Rails.application.routes.draw do
  scope 'api' do
    devise_for :users
    use_doorkeeper

    scope 'v2' do
      jsonapi_resources :lists, only: [ :create, :update, :destroy, :index ]
      jsonapi_resources :tasks do
        post :skip, on: :member
        post :modify_instance, on: :member
        post :update_this_and_future, on: :member
        post :delete_this_and_future, on: :member
      end
      jsonapi_resources :recurrence_rules
    end
  end
end
