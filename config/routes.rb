Rails.application.routes.draw do
  scope 'api' do
    devise_for :users
    use_doorkeeper

    scope 'v2' do
      jsonapi_resources :lists, only: [ :create, :update, :destroy, :index ]
      jsonapi_resources :tasks
    end

    scope 'v3' do
      jsonapi_resources :lists, only: [ :create, :update, :destroy, :index ]
      jsonapi_resources :tasks
      
      # New recurring task endpoints
      jsonapi_resources :recurring_task_templates do
        member do
          post :deactivate
        end
      end
      
      jsonapi_resources :recurring_task_instances, only: [:index, :show] do
        member do
          post :create_task
          post :skip
        end
      end
      
      jsonapi_resources :recurring_task_overrides
    end
  end
end
