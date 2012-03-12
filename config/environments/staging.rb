OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are enabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Set log level
  config.log_level = :debug

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Root URL of application (used in sending emails)
  config.root_url = ''  # You should override this in staging_custom.rb

  # Which sort of cache to use
  config.cache_store = :memory_store, {
    :size => 32 * (1024 * 1024), #MiB
    :compress => true,
    :compress_threshold => 1 * (1024 * 1024), #MiB
    :expires_in => 30.minutes,
    :race_condition_ttl => 2.minutes
  }

end

# Load custom configuration
require File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb") if File.exists?(File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb"))
