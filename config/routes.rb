Rails.application.routes.draw do
  post 'sign-in', to: 'sessions#create', as: :sign_in
  delete 'sign-out', to: 'sessions#destroy', as: :sign_out

  resources :favourites
end
