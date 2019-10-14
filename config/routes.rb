Rails.application.routes.draw do
  resources :projects
  resources :workflows
  resources :transcriptions
end
