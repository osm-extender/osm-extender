OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are enabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

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

  # How to send email
  config.action_mailer.delivery_method = :mailgun 
  config.action_mailer.mailgun_settings = { 
    api_key: Figaro.env.mailgun_api_key!, 
    domain: Figaro.env.mailgun_domain!
  }

  # URL Options (copy/complete into staging_custom.rb)
  Rails.application.routes.default_url_options = {
    :protocol => 'https',
    :host => 'localhost',
  }

  # Whether to dump (or not) the schema after performing migrations
  config.active_record.dump_schema_after_migration = false

end


ActiveSupport::Deprecation.silenced = true
ActionController::Parameters.action_on_unpermitted_parameters ||= :raise


# Load custom configuration
require File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb") if File.exists?(File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb"))
