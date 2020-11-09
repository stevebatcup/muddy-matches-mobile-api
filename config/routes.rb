Rails.application.routes.draw do
  post 'sign-in', to: 'sessions#new', as: :sign_in
end
