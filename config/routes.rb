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

  # API routes
  get "api/lawyers", to: "users#lawyers"
  get "api/clients", to: "users#clients"
  get "api/lawyer/:id/clients", to: "users#lawyer_clients"
  get "api/user/profile/:role/:id", to: "users#profile"
  get "api/notifications/:user_id", to: "notifications#index"
  put "api/user/:id", to: "users#update_profile"
  get "api/lawyer/:id/available_cases", to: "cases#available_cases"
end
