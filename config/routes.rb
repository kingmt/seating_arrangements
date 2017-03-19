Rails.application.routes.draw do
  #resources :people
  #resources :tables

  namespace :api do
    resources :tables, only: [:create, :update, :index, :show, :destroy] do
      resources :seats, only: [:create, :update, :destroy]
    end
    resources :people, only: [:create, :index, :show, :update, :destroy]
  end
end
