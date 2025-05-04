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

  resources :cases, only: [:create] do
    post 'accept', on: :member
  end

  # ✅ New
  get "api/lawyers", to: "users#lawyers"
  get "api/clients", to: "users#clients"
  get "api/lawyer/:id/clients", to: "users#lawyer_clients"
  get "api/user/profile/:role/:id", to: "users#profile"
  get "api/notifications/:user_id", to: "notifications#index"
  put "api/user/:id", to: "users#update_profile"
end
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

  resources :cases, only: [:create, :index] do
    post 'accept', on: :member
  end

  # Lawyer search route
  get "api/lawyers", to: "users#lawyers"

  # Client search route
  get "api/clients", to: "users#clients"

  # Get clients for a specific lawyer
  get "/api/lawyer/:id/clients", to: "users#lawyer_clients"

  # Profile management route
  put "api/user/:id", to: "users#update_profile"

  # Fetch profile route by role and ID
  get "api/user/profile/:role/:id", to: "users#profile"
end
