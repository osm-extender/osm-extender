SectionManagementSystem::Application.routes.draw do
  get "welcome/index"

  get 'signin' => 'sessions#new', :as => 'signin'
  get 'signout' => 'sessions#destroy', :as => 'signout'
  get 'signup' => 'users#new', :as => 'signup'
  
  match 'activate_account/:id' => 'users#activate_account', :as => 'activate_account'
  match 'reset_password/:token' => 'password_resets#edit', :as => 'reset_password'

  resources :users
  resources :sessions
  resources :password_resets

  root :to => 'welcome#index'
end
