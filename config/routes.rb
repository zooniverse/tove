Rails.application.routes.draw do
  get '/', to: 'status#show'

  post '/import', to: 'caesar#import'

  resources :projects, only: [:index, :show] do
    get 'export', on: :member
  end
  resources :workflows, only: [:index, :show] do
    get 'export', on: :member
  end
  resources :transcriptions, only: [:index, :show, :update] do
    get 'export', on: :member
    get 'export_group', on: :collection
    patch 'unlock', on: :member
  end
end
