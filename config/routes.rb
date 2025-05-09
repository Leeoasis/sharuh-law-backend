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
    resources :cases, only: [:index, :show, :create, :update, :destroy] do
      patch :accept, on: :member
      collection do
        post :check_lawyers
      end
    end
  end

  # ✅ Allow POST /cases/:id/accept (for current frontend usage)
  post '/cases/:id/accept', to: 'cases#accept'

  # Top-level case route (optional global view)
  resources :cases, only: [:index]

  # Lawyer search
  get "api/lawyers", to: "users#lawyers"

  # Client search
  get "api/clients", to: "users#clients"

  # ✅ Lawyer's accepted clients
  get "api/lawyer/:id/clients", to: "users#lawyer_clients"

  # ✅ Lawyer's available cases
  get "api/lawyer/:id/available_cases", to: "cases#available_cases"

  # ✅ Notifications for any user
  get "api/notifications/:user_id", to: "notifications#index"

  # Profile update + view
  put "api/user/:id", to: "users#update_profile"
  get "api/user/profile/:role/:id", to: "users#profile"

  delete '/logout', to: 'users/sessions#destroy'

end
