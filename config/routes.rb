Rails.application.routes.draw do
  resources :projects, only: [:index, :show]
  resources :workflows, only: [:index, :show]
  resources :transcriptions, only: [:index, :show, :update]
end
