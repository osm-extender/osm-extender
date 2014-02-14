OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Which sort of cache to use
  config.cache_store = :memory_store, {
    :size => 32 * (1024 * 1024), #MiB
    :compress => true,
    :compress_threshold => 1 * (1024 * 1024), #MiB
    :expires_in => 30.minutes,
    :race_condition_ttl => 2.minutes
  }

  # URL Options (copy/complete into production_custom.rb)
  Rails.application.routes.default_url_options = {
    :protocol => 'https',
    :host => 'localhost',
  }

  # Mailer options (copy/complete into production_custom.rb)
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

  # Mail sending options (copy/complete relevant version into production_custom.rb)
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
  # OSM options (copy/complete into production_custom.rb)
#  Osm::configure(
#    :api => {
#      :default_site => :osm,
#      :osm => {
#        :id    => GET THIS FROM ED,
#        :token => GET THIS FROM ED,
#        :name  => GIVE THIS TO ED,
#      },
#      :debug   => true
#    },
#    :cache => {
#      :cache  => Rails.cache,
#      :ttl    => 30
#    },
#  )

  # ReCAPTCHA options (copy/complete into production_custom.rb)
#  Recaptcha.configure do |config|
#    config.public_key  = YOUR PUBLIC KEY HERE
#    config.private_key = YOUR PRIVATE KEY HERE
#  end
end


# Load custom configuration
require File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb") if File.exists?(File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb"))

