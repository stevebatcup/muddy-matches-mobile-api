Rails.application.routes.draw do
  post 'sign-in', to: 'sessions#create', as: :sign_in
  delete 'sign-out', to: 'sessions#destroy', as: :sign_out

  resources :favourites
  get 'fans', to: 'favourites#index', as: :fans, fans: true
  get 'mutuals', to: 'favourites#index', as: :mutuals, mutuals: true
  delete 'favourited/:id', to: 'favourites#destroy', as: :delete_favourited, favourited: true
end
