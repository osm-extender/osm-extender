OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are enabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Set log level
  config.log_level = :debug

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Which sort of cache to use
  config.cache_store = :memory_store, {
    :size => 32 * (1024 * 1024), #MiB
    :compress => true,
    :compress_threshold => 1 * (1024 * 1024), #MiB
    :expires_in => 30.minutes,
    :race_condition_ttl => 2.minutes
  }

  # URL Options (copy/complete into staging_custom.rb)
  Rails.application.routes.default_url_options = {
    :protocol => 'https',
    :host => 'localhost',
  }

  # Mailer options (copy/complete into staging_custom.rb)
#  ReminderMailer.send :default, {
#    :from => '',                # Can be in the format - "Name" <email_address>
#    'return-path' => '',        # Should be the email address portion of from
#  }
#  UserMailer.send :default, {
#    :from => '',                # Can be in the format - "Name" <email_address>
#    'return-path' => '',        # Should be the email address portion of from
#  }
#  NotifierMailer.send :default, {
#    :from => '',                # Can be in the format - "Name" <email_address>
#    'return-path' => '',        # Should be the email address portion of from
#  }
#  NotifierMailer.options = {
#    :contact_form__to => '',    # Can be in the format - "Name" <email_address>
#    :reminder_failed__to => '', # Can be in the format - "Name" <email_address>
#    :exception__to => '',       # Can be in the format - "Name" <email_address>
#  }

  # Mail sending options (copy/complete relevant version into staging_custom.rb)
  # Sendmail
#  ActionMailer::Base.delivery_method = :sendmail
#  ActionMailer::Base.sendmail_settings = {
#    :location => '',
#  }
  # SMTP
#  ActionMailer::Base.delivery_method = :smtp
#  ActionMailer::Base.smtp_settings = {
#    :address              => '',
#    :port                 => '',
#    :domain               => '',
#    :user_name            => '',
#    :password             => '',
#    :authentication       => 'plain',
#    :enable_starttls_auto => true
#  }

end

ActionDispatch::Callbacks.to_prepare do
  # OSM options (copy/complete into staging_custom.rb)
#  Osm::configure(
#    :api => {
#      :default_site => :osm,
#      :osm => {
#        :id    => GET THIS FROM ED,
#        :token => GET THIS FROM ED,
#        :name  => GIVE THIS TO ED,
#      },
#    },
#    :cache => {
#      :cache  => Rails.cache,
#      :ttl    => 30
#    },
#  )

  # ReCAPTCHA options (copy/complete into staging_custom.rb)
#  Recaptcha.configure do |config|
#    config.public_key  = YOUR PUBLIC KEY HERE
#    config.private_key = YOUR PRIVATE KEY HERE
#  end
end


# Load custom configuration
require File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb") if File.exists?(File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb"))

