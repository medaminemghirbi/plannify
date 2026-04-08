Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  resources :gyms
  resource :settings, only: [:edit, :update], controller: "settings"
  resources :coaches, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :clients, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :training_groups do
    member do
      post :add_member
      delete :remove_member
    end
  end
  resources :planning_sessions, only: [:index, :new, :create, :edit, :update, :destroy]
  get "statistics", to: "statistics#index"
  resources :payments, only: [:index, :new, :create, :edit, :update, :destroy] do
    resource :receipt, only: [:new, :create, :show], controller: "payment_receipts" do
      get :pdf
    end
  end
  resources :admins, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :documents do
    member do
      get :download
      get :pdf
    end
  end

  get "dashboard", to: "dashboard#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
