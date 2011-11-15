SectionManagementSystem::Application.routes.draw do

  get 'welcome/index'
  get 'my_page' => 'my_page#index', :as => 'my_page'

  get 'signin' => 'sessions#new', :as => 'signin'
  get 'signout' => 'sessions#destroy', :as => 'signout'
  get 'signup' => 'users#new', :as => 'signup'
  
  get 'my_account' => 'my_account#show', :as => 'my_account'
  get 'my_account/change_password' => 'my_account#change_password', :as => 'change_my_password'
  put 'my_account/update_password' => 'my_account#update_password', :as => 'update_my_password'

  get 'my_account/edit' => 'my_account#edit', :as => 'edit_my_account'
  put 'my_account/update' => 'my_account#update', :as => 'update_my_account'

  match 'activate_account/:token' => 'users#activate_account', :as => 'activate_account'
  match 'reset_password/:token' => 'password_resets#edit', :as => 'reset_password'

  resources :users
  get 'users/reset_password/:id' => 'users#reset_password', :as => 'reset_password_user'
  get 'users/resend_activation/:id' => 'users#resend_activation', :as => 'resend_activation_user'

  resources :sessions
  resources :password_resets

  root :to => 'welcome#index'
end
