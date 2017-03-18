Rails.application.routes.draw do
  resources :people
  resources :tables

  namespace :api do
    resources :tables do
      resources :seats
    end
    resources :people
  end
end
