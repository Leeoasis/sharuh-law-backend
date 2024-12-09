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

  resources :cases, only: [ :index, :show, :create, :update, :destroy ]

  # Lawyer search route
  get "api/lawyers", to: "users#lawyers"

  # Client search route
  get "api/clients", to: "users#clients"

# Profile management route
put "api/user/:id", to: "users#update_profile"

  # Other routes
  # root to: "home#index" # Replace with your desired root path
end
