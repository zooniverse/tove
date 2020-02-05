Rails.application.routes.draw do
  get '/', to: 'status#show'

  post '/import', to: 'caesar#import'

  resources :projects, only: [:index, :show]
  resources :workflows, only: [:index, :show]
  resources :transcriptions, only: [:index, :show, :update]
end
