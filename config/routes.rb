Rails.application.routes.draw do
  root "sites#root"

  resources :tasks
end
