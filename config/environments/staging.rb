OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Expands the lines which load the assets
  config.assets.debug = true

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
