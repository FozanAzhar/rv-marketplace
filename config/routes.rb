Rails.application.routes.draw do
  # Bonus: interactive API docs generated from RSpec (rswag).
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get "up" => "rails/health#show", as: :rails_health_check

  # Token auth — not in the brief's resource list but required for protected routes.
  post "auth/signup", to: "auth#create"
  post "auth/login", to: "auth#login"

  # Core resources: listings with nested booking requests and messages.
  resources :listings, controller: "rv_listings" do
    resources :bookings, only: [ :create ]
    resources :messages, only: [ :index, :create ]
  end

  # Top-level bookings for listing a user's requests and owner confirm/reject.
  resources :bookings, only: [ :index ] do
    member do
      patch :confirm
      patch :reject
    end
  end
end