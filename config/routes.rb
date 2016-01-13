Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users

  get "home/index"
  root "home#index"

  resources :studies, only: :show
end
