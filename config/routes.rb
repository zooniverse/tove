Rails.application.routes.draw do
  resources :projects, only: [:index]
  resources :workflows, only: [:index]
  resources :transcriptions, only: [:index, :update]
end
