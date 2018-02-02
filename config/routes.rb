OSMExtender::Application.routes.draw do

  get 'index' => 'static#welcome', :as => 'welcome_page'
  get 'my_page' => 'static#my_page', :as => 'my_page'
  get 'check_osm_setup' => 'static#check_osm_setup', :as => 'check_osm_setup'
  get 'help' => 'static#help', :as => 'help'

  get 'signin' => 'sessions#new', :as => 'signin'
  post 'signin' => 'sessions#create'
  get 'signout' => 'sessions#destroy', :as => 'signout'
  get 'signup' => 'users#new', :as => 'signup'
  get 'session/change_section' => 'sessions#change_section', :as => 'change_section'

  get 'contact_us' => 'contact_us#form', :as => 'contact_us'
  post 'contact_us' => 'contact_us#send_form', :as => 'send_contact_us'

  get 'legal/cookie_policy.html', to: 'static#cookie_policy', format: false, as: 'legal_cookie_policy'
  get 'legal/privacy_policy.html', to: 'static#privacy_policy', format: false, as: 'legal_privacy_policy'

  get 'my_account' => 'my_account#show', :as => 'my_account'
  get 'my_account/change_password' => 'my_account#change_password', :as => 'change_my_password'
  put 'my_account/update_password' => 'my_account#update_password', :as => 'update_my_password'
  get 'my_account/edit' => 'my_account#edit', :as => 'edit_my_account'
  put 'my_account/update' => 'my_account#update', :as => 'update_my_account'
  get 'my_account/connect_to_osm' => 'my_account#connect_to_osm', :as => 'connect_to_osm'
  post 'my_account/connect_to_osm' => 'my_account#connect_to_osm2', :as => 'connect_to_osm2'
  get 'my_account/delete' => 'my_account#confirm_delete', :as => 'confirm_delete_my_account'
  post 'my_account/delete' => 'my_account#delete', :as => 'delete_my_account'

  post 'my_preferences' => 'my_preferences#update', :as => 'update_my_preferences'
  post 'my_preferences/save_custom_sizes' => 'my_preferences#save_custom_sizes', :as => 'save_custom_sizes'

  post 'email_lists/preview' => 'email_lists#preview', :as => 'preview_email_list'
  get 'email_lists/:id/get_addresses' => 'email_lists#get_addresses', :as => 'email_list_addresses'
  post 'email_lists/multiple' => 'email_lists#multiple', :as => 'multiple_email_list'
  resources :email_lists

  get 'activate_account/:token' => 'users#activate_account', :as => 'activate_account'
  get 'reset_password/:token' => 'password_resets#edit', :as => 'reset_password'
  get 'unlock_account/:token' => 'users#unlock_account', :as => 'unlock_account'

  resources :users
  get 'users/:id/reset_password' => 'users#reset_password', :as => 'reset_password_user'
  get 'users/:id/resend_activation' => 'users#resend_activation', :as => 'resend_activation_user'
  post 'users/:id/unlock' => 'users#unlock', :as => 'unlock_user'
  post 'users/:id/become' => 'users#become', :as => 'become_user'

  get 'programme_review/balanced' => 'programme_review#balanced', :as => 'programme_review_balanced'
  get 'programme_review/balanced_data' => 'programme_review#balanced_data', :as => 'programme_review_balanced_data'

  delete 'programme_review_balanced_cache/:id(.:format)' => 'programme_review_balanced_cache#destroy', :as => 'programme_review_balanced_cach'
  post 'programme_review_balanced_cache/delete_multiple(.:format)' => 'programme_review_balanced_cache#destroy_multiple', :as => 'delete_multiple_programme_review_balanced_cache'

  get 'map_members' => 'map_members#index', :as => 'map_members_index'
  get 'map_members/multiple' => 'map_members#multiple_page', :as => 'map_members_multiple'
  get 'map_members/multiple/data' => 'map_members#multiple_data', :as => 'map_members_multiple_data'
  get 'map_members/:section_id' => 'map_members#page', :as => 'map_members'
  get 'map_members/:section_id/data' => 'map_members#data', :as => 'map_members_data'

  resources :password_resets

  resources :email_reminders do
    resources :email_reminder_shares, :as => 'shares', :only => [:index, :destroy, :new, :create], :path => 'shares'
    post 'shares/:id/resend_notification' => 'email_reminder_shares#resend_shared_with_you', :as => 'resend_share_notification'
    resources :email_reminder_items, :as => 'items', :path => 'items'
    resources :email_reminder_item_birthdays, :as => 'item_birthdays', :path => 'item_birthdays'
    resources :email_reminder_item_due_badges, :as => 'item_due_badges', :path => 'item_due_badges'
    resources :email_reminder_item_events, :as => 'item_events', :path => 'item_events'
    resources :email_reminder_item_not_seens, :as => 'item_not_seens', :path => 'item_not_seen'
    resources :email_reminder_item_advised_absences, :as => 'item_advised_absences', :path => 'item_advised_absence'
    resources :email_reminder_item_programmes, :as => 'item_programmes', :path => 'item_programme'
    resources :email_reminder_item_notepads, :as => 'item_notepads', :path => 'item_notepad'
  end
  get 'email_reminders/:id/sample' => 'email_reminders#sample', :as => 'sample_email_reminder'
  get 'email_reminders/:id/preview' => 'email_reminders#preview', :as => 'preview_email_reminder'
  get 'email_reminders/:id/send_email' => 'email_reminders#send_email', :as => 'send_email_reminder'
  post 'email_reminders/:id/re_order' => 'email_reminders#re_order', :as => 're_order_email_reminder'

  get 'email_reminder_subscriptions/:id/edit' => 'email_reminder_subscriptions#edit', :as => 'edit_email_reminder_subscription'
  post 'email_reminder_subscriptions/:id/edit' => 'email_reminder_subscriptions#change', :as => 'change_email_reminder_subscription'

  get 'osm_flexi_records' => 'osm_flexi_records#index', :as => 'osm_flexi_records'
  get 'osm_flexi_records/:section_id' => 'osm_flexi_records#index_for_section', :as => 'osm_flexi_records_for_section'
  get 'osm_flexi_records/:section_id/:record_id' => 'osm_flexi_records#show', :as => 'osm_flexi_record'

  get 'osm_search_members' => 'osm_search_members#search_form', :as => 'osm_search_members_form'
  post 'osm_search_members' => 'osm_search_members#search_results', :as => 'osm_search_members_results'

  get 'osm_exports' => 'osm_exports#index', :as => 'osm_exports'
  post 'osm_exports/flexi_record' => 'osm_exports#flexi_record', :as => 'osm_exports_flexi_record'
  post 'osm_exports/members' => 'osm_exports#members', :as => 'osm_exports_members'
  post 'osm_exports/programme_activities' => 'osm_exports#programme_activities', :as => 'osm_exports_programme_activities'
  post 'osm_exports/programme_meetings' => 'osm_exports#programme_meetings', :as => 'osm_exports_programme_meetings'

  get 'osm_myscout_payments/calculator' => 'osm_myscout_payments#calculator', :as => 'osm_myscout_payments_calculator'

  get 'reports' => 'reports#index', :as => 'reports'
  get 'reports/calendar' => 'reports#calendar', :as => 'calendar_report'
  get 'reports/event_attendance' => 'reports#event_attendance', :as => 'event_attendance_report'
  get 'reports/due_badges' => 'reports#due_badges', :as => 'due_badges_report'
  get 'reports/awarded_badges' => 'reports#awarded_badges', :as => 'awarded_badges_report'
  get 'reports/missing_badge_requirements' => 'reports#missing_badge_requirements', :as => 'missing_badge_requirements_report'
  get 'reports/members_photos' => 'reports#members_photos', :as => 'members_photos_report'
  get 'reports/badge_completion_matrix' => 'reports#badge_completion_matrix', :as => 'badge_completion_matrix_report'
  get 'reports/badge_stock_check' => 'reports#badge_stock_check', :as => 'badge_stock_check_report'
  get 'reports/planned_badge_requirements' => 'reports#planned_badge_requirements', :as => 'planned_badge_requirements_report'
  get 'reports/leader_access_audit' => 'reports#leader_access_audit', :as => 'leader_access_audit'

  resources :announcements
  post 'announcements/:id/hide' => 'announcements#hide', :as => 'hide_announcement'

  resources :automation_tasks, as: 'automation_tasks', except: [:show]
  resources :automation_task_birthday_badges, as: 'automation_task_birthday_badges', path: 'automation_tasks/birthday_badges', except: [:show]
  post 'automation_tasks/birthday_badges/perform_task' => 'automation_task_birthday_badges#perform_task', :as => 'automation_task_birthday_badge_perform'
  resources :automation_task_chief_scout_awards, as: 'automation_task_chief_scout_awards', path: 'automation_tasks/chief_scout_awards', except: [:show]
  post 'automation_tasks/chief_scout_awards/perform_task' => 'automation_task_chief_scout_awards#perform_task', :as => 'automation_task_chief_scout_award_perform'
  resources :automation_task_first_aids, as: 'automation_task_first_aids', path: 'automation_tasks/first_aids', except: [:show]
  post 'automation_tasks/first_aids/perform_task' => 'automation_task_first_aids#perform_task', :as => 'automation_task_first_aid_perform'
  resources :automation_task_leaderships, as: 'automation_task_leaderships', path: 'automation_tasks/leaderships', except: [:show]
  post 'automation_tasks/leaderships/perform_task' => 'automation_task_leaderships#perform_task', :as => 'automation_task_leadership_perform'

  get 'statistics' => 'statistics#index', :as => 'statistics'
  get 'statistics/users' => 'statistics#users', :as => 'user_statistics'
  get 'statistics/email_reminders' => 'statistics#email_reminders', :as => 'email_reminders_statistics'
  get 'statistics/sections' => 'statistics#sections', :as => 'sections_statistics'
  get 'statistics/usage' => 'statistics#usage', :as => 'usage_statistics'
  get 'statistics/automation_tasks' => 'statistics#automation_tasks', :as => 'automation_tasks_statistics'

  get 'status' => 'status#index', :as => 'status'

  get 'delayed_jobs' => 'delayed_job#index', :as => 'delayed_jobs'

  root :to => 'static#welcome'
end
