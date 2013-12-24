# The first thing you need to configure is which modules you need in your app.
# The default is nothing which will include only core features (password encryption, login/logout).
# Available submodules are: :user_activation, :http_basic_auth, :remember_me, 
# :reset_password, :session_timeout, :brute_force_protection, :activity_logging, :external
Rails.application.config.sorcery.submodules = [:session_timeout, :brute_force_protection, :user_activation, :reset_password]

# Here you can configure each submodule's features.
Rails.application.config.sorcery.configure do |config|
  # -- core --
  # config.not_authenticated_action = :not_authenticated              # what controller action to call for
                                                                      # non-authenticated users. 
                                                                      # You can also override 'not_authenticated' 
                                                                      # instead.
                                                                      
  # config.save_return_to_url = true                                  # when a non logged in user tries to enter 
                                                                      # a page that requires login, 
                                                                      # save the URL he wanted to reach, 
                                                                      # and send him there after login, using
                                                                      # 'redirect_back_or_to'.

  # -- session timeout --                                             
  # config.session_timeout = 3600                                     # how long in seconds to keep the session alive.
  config.session_timeout = (Rails.env.development? ? 1.day : 30.minutes).to_i
  # config.session_timeout_from_last_action = false                   # use the last action as the beginning of 
                                                                      # session timeout.
  config.session_timeout_from_last_action = true
  
  # -- http_basic_auth --
  # config.controller_to_realm_map = {"application" => "Application"} # What realm to display for which controller name.
                                                                      # For example {"My App" => "Application"}
  
  # -- external --
  # config.external_providers = []                                    # What providers are supported by this app, 
                                                                      # i.e. [:twitter, :facebook] .
  # 
  # config.twitter.key = "eYVNBjBDi33aa9GkA3w"
  # config.twitter.secret = "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8"
  # config.twitter.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=twitter"
  # config.twitter.user_info_mapping = {:email => "screen_name"}
  # 
  # config.facebook.key = "34cebc81c08a521bc66e212f947d73ec"
  # config.facebook.secret = "5b458d179f61d4f036ee66a497ffbcd0"
  # config.facebook.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=facebook"
  # config.facebook.user_info_mapping = {:email => "name"}
  
  # --- user config ---
  config.user_config do |user|
    # -- core --
    # user.username_attribute_name = :username                                        # change default username
                                                                                      # attribute, for example, 
                                                                                      # to use :email as the login.
    user.username_attribute_names = [:email_address]
                                                                                      
    # user.password_attribute_name = :password                                        # change *virtual* password
                                                                                      # attribute, the one which is used
                                                                                      # until an encrypted one is
                                                                                      # generated.
                                                                                      
    # user.email_attribute_name = :email                                              # change default email attribute.
    user.email_attribute_name = :email_address
    
    # user.crypted_password_attribute_name =  :crypted_password                       # change default crypted_password
                                                                                      # attribute.
                                                                                      
    # user.salt_join_token = ""                                                       # what pattern to use to join the
                                                                                      # password with the salt
                                                                                      
    # user.salt_attribute_name = :salt                                                # change default salt attribute.
    
    # user.stretches = nil                                                            # how many times to apply
                                                                                      # encryption to the password.
                                                                                      
    # user.encryption_key = nil                                                       # encryption key used to encrypt
                                                                                      # reversible encryptions such as
                                                                                      # AES256.
                                                                                      
    # user.custom_encryption_provider = nil                                           # use an external encryption 
                                                                                      # class.
                                                                                      
    # user.encryption_algorithm = :bcrypt                                             # encryption algorithm name. See
                                                                                      # 'encryption_algorithm=' for
                                                                                      # available options.
                                                                                      
    # user.subclasses_inherit_config = false                                          # make this configuration
                                                                                      # inheritable for subclasses.
                                                                                      # Useful for ActiveRecord's STI.
                                                                                      
    # -- user_activation --                                                           
    # user.activation_state_attribute_name = :activation_state                        # the attribute name to hold
                                                                                      # activation state
                                                                                      # (active/pending).
                                                                                      
    # user.activation_token_attribute_name = :activation_token                        # the attribute name to hold
                                                                                      # activation code (sent by email).
                                                                                      
    # user.activation_token_expires_at_attribute_name = :activation_token_expires_at  # the attribute name to hold
                                                                                      # activation code expiration date. 
                                                                                      
    # user.activation_token_expiration_period =  nil                                  # how many seconds before the
                                                                                      # activation code expires. nil for
                                                                                      # never expires.
    user.activation_token_expiration_period = 1.week
                                                                                      
    # user.user_activation_mailer = nil                                               # your mailer class. Required.
    user.user_activation_mailer = UserMailer
    
    # user.activation_needed_email_method_name = :activation_needed_email             # activation needed email method
                                                                                      # on your mailer class.
    user.activation_needed_email_method_name = :activation_needed
                                                                                      
    # user.activation_success_email_method_name = :activation_success_email           # activation success email method
                                                                                      # on your mailer class.
    user.activation_success_email_method_name = :activation_success
                                                                                      
    # user.prevent_non_active_users_to_login = true                                   # do you want to prevent or allow
                                                                                      # users that did not activate by
                                                                                      # email to login?                     
                                                                  
    # -- reset_password --                                        
    # user.reset_password_token_attribute_name = :reset_password_token                          # reset password code
                                                                                                # attribute name.
                                                                                                
    # user.reset_password_token_expires_at_attribute_name = :reset_password_token_expires_at    # expires at attribute
                                                                                                # name.
                                                                                                
    # user.reset_password_email_sent_at_attribute_name = :reset_password_email_sent_at          # when was email sent,
                                                                                                # used for hammering
                                                                                                # protection.
                                                                                                
    # user.reset_password_mailer = nil                                                          # mailer class. Needed.
    user.reset_password_mailer = UserMailer
    
    # user.reset_password_email_method_name = :reset_password_email                             # reset password email
                                                                                                # method on your mailer
                                                                                                # class.
    user.reset_password_email_method_name = :reset_password
                                                                                                
    # user.reset_password_expiration_period = nil                                               # how many seconds
                                                                                                # before the reset
                                                                                                # request expires. nil
                                                                                                # for never expires.
    user.reset_password_expiration_period = 15.minutes
                                                                                                
    # user.reset_password_time_between_emails = 5 * 60                                          # hammering protection,
                                                                                                # how long to wait
                                                                                                # before allowing
                                                                                                # another email to be
                                                                                                # sent.
    user.reset_password_time_between_emails = Rails.env.development? ? 0 : 5.minutes                                         # hammering protection,
                                                                  
    # -- brute_force_protection --                                
    # user.failed_logins_count_attribute_name = :failed_logins_count                  # failed logins attribute name.
    
    # user.lock_expires_at_attribute_name = :lock_expires_at                          # this field indicates whether
                                                                                      # user is banned and when it will
                                                                                      # be active again.
                                                                                      
    # user.consecutive_login_retries_amount_limit = 50                                # how many failed logins allowed.
    user.consecutive_login_retries_amount_limit = 3
    
    # user.login_lock_time_period = 60 * 60                                           # how long the user should be
                                                                                      # banned. in seconds. 0 for
                                                                                      # permanent.
    user.login_lock_time_period = 1.hour

    # Unlock token attribute name
    # Default: `:unlock_token`
    #
    # user.unlock_token_attribute_name =

    # Unlock token mailer method
    # Default: `:send_unlock_token_email`
    #
    # user.unlock_token_email_method_name =

    # when true sorcery will not automatically
    # send email with unlock token
    # Default: `false`
    #
    # user.unlock_token_mailer_disabled = true
    user.unlock_token_mailer_disabled = true

    # Unlock token mailer class
    # Default: `nil`
    # 
    # user.unlock_token_mailer = UserMailer

                                                                  
    # -- activity logging --                                      
    # user.last_login_at_attribute_name = :last_login_at                              # last login attribute name.
    # user.last_logout_at_attribute_name = :last_logout_at                            # last logout attribute name.
    # user.last_activity_at_attribute_name = :last_activity_at                        # last activity attribute name.
    # user.activity_timeout = 10 * 60                                                 # how long since last activity is
                                                                                      # the user defined logged out?
                                                                                      
    # -- external --                                                                     
    # user.authentications_class = nil                                                # class which holds the various
                                                                                      # external provider data for this
                                                                                      # user.
                                                                                      
    # user.authentications_user_id_attribute_name = :user_id                          # user's identifier in
                                                                                      # authentications class.
                                                                                      
    # user.provider_attribute_name = :provider                                        # provider's identifier in
                                                                                      # authentications class.
                                                                                      
    # user.provider_uid_attribute_name = :uid                                         # user's external unique
                                                                                      # identifier in authentications
                                                                                      # class.
  end

  # This line must come after the 'user config' block.
  config.user_class = "User"                                                          # define which model authenticates
                                                                                      # with sorcery.
end
