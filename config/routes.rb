Rails.application.routes.draw do
  root "sites#root"

  resources :users, except: [:show, :index]
  resources :sessions, only: [:new, :create, :destroy]
  resources :tasks, only: [:index, :update]
  namespace :tasks do
    get 'expired'
  end

  resources :results, only: :update
end
