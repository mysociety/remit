Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users

  get "home/index"
  root "home#index"

  resources :studies, only: :show do
    resources :documents, only: :create
    resources :study_notes, only: :create
    # A generic create controller action that allows us to create a
    # publication, dissemination or study_impact
    post "outputs/create"
    resources :study_enabler_barriers do
      post :create_multiple, on: :collection
    end
  end

  # Users only have a list of studies at the moment, devise takes care of the
  # rest
  resources :users, only: []  do
    resources :studies, only: :index
  end
end
