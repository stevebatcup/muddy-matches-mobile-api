Rails.application.routes.draw do
  post 'sign-in', to: 'sessions#create', as: :sign_in
  delete 'sign-out', to: 'sessions#destroy', as: :sign_out
  post 'register', to: 'registrations#create', as: :register

  resources :favourites, only: %i[index create destroy]
  get 'fans', to: 'favourites#index', as: :fans, fans: true
  get 'mutuals', to: 'favourites#index', as: :mutuals, mutuals: true
  delete 'favourited/:id', to: 'favourites#destroy', as: :delete_favourited, favourited: true

  resources :conversations, only: :index
  resources :messages, only: %i[show create]

  post 'subscribed', to: 'subscriptions#create', as: :subscribed
  post 'search', to: 'search#index', as: :search
  post 'approve-connect', to: 'connects#create', as: :approve_connect, mode: :approve
  post 'reject-connect', to: 'connects#create', as: :reject_connect, mode: :reject
end
