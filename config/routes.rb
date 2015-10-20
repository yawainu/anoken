Rails.application.routes.draw do
  root "sites#root"

  resources :tasks, only: [:index, :update]
  namespace :tasks do
    get 'expired'
  end
end
