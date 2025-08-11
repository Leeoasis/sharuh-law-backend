Rails.application.routes.draw do
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  },
  controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Nested case routes under each user
  resources :users do
    resources :cases, only: [:index, :show, :create, :update, :destroy] do
      patch :accept, on: :member
      collection do
        post :check_lawyers
      end
    end
  end

  # Global case routes (used by admin for updates)
  post '/cases/:id/accept', to: 'cases#accept'
  resources :cases, only: [:index, :update] # ✅ added :update

  # Admin-specific view for unmatched cases
  get "/admin-cases", to: "cases#admin_index"

  # API utility endpoints
  get "api/lawyers", to: "users#lawyers"
  get "api/clients", to: "users#clients"
  get "api/lawyer/:id/clients", to: "users#lawyer_clients"
  get "api/lawyer/:id/available_cases", to: "cases#available_cases"
  get "api/notifications/:user_id", to: "notifications#index"
  put "api/user/:id", to: "users#update_profile"
  get "api/user/profile/:role/:id", to: "users#profile"

  # Admin namespace (optional)
  namespace :admin do
    resources :cases, only: [:index, :update]
  end

  delete '/logout', to: 'users/sessions#destroy'
end
