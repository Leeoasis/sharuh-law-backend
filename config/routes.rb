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

  resources :users do
    resources :cases, only: [ :index, :show, :create, :update, :destroy ] do
      patch :accept, on: :member # Adding accept as a member action
      collection do
        post :check_lawyers # Adding check_lawyers as a collection action
      end
    end
  end

  # Add this line to create a top-level route for cases
  resources :cases, only: [ :index ]

  # Lawyer search route
  get "api/lawyers", to: "users#lawyers"

  # Client search route
  get "api/clients", to: "users#clients"

  # Profile management route
  put "api/user/:id", to: "users#update_profile"

  # Fetch profile route by role and ID
  get "api/user/profile/:role/:id", to: "users#profile"

  # Other routes
  # root to: "home#index" # Replace with your desired root path
end
