Rails.application.routes.draw do
  get '/', to: 'status#show'

  resources :projects, only: [:index, :show] do
    get 'export', on: :member
  end
  resources :workflows, only: [:index, :show] do
    get 'export', on: :member
  end
  resources :transcriptions, only: [:index, :show, :update] do
    get 'export', on: :member
    get 'export', on: :collection
  end

end
