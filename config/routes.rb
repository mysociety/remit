Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users

  root "home#index"

  resources :studies, only: :show do
    resources :documents, only: :create
    resources :study_notes, only: :create
    # A generic create controller action that allows us to create a new
    # publication, dissemination or study_impact
    get "outputs/new"
    post "outputs/create"
    put "progress_to_delivery"
    put "progress_to_completion"
    resources :study_invites, only: :create
    resources :delivery_updates, only: [:new, :create]
  end

  resources :documents, only: :show

  # Users only have a list of studies at the moment, devise takes care of the
  # rest
  resources :users, only: []  do
    resources :studies, only: :index
  end

  get "/search", to: "search#index"
end
