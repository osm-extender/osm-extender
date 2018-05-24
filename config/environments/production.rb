OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are enabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = true

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

  # Log to STDOUT
  logger = Logger.new(STDOUT)
  logger.formatter = Logger::Formatter.new
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  STDOUT.sync = true

  # Set log level - :debug, :info, :warn, :error, :fatal, or :unknown
  config.log_level = :info

  # Turn of colour in rails log
  config.colorize_logging = false

  # Automatically tag log messages
  config.log_tags = [ :uuid ]

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :notify

  # Which sort of cache to use
  config.cache_store = :redis_store, {
    host: Figaro.env.redis_host || 'localhost',
    port: Figaro.env.redis_port? ? Figaro.env.redis_port.split(':').last.to_i : 6379,  # Sometimes it appears as tcp://<IP-ADDRESS>:6379
    db: Figaro.env.redis_db? ? Figaro.env.redis_db.to_i : 0,
    password: Figaro.env.redis_password || nil,
    expires_in: Figaro.env.redis_expires_in? ? Figaro.env.redis_expires_in.to_i : 10.minutes,
    namespace: Figaro.env.redis_namespace || "osmx.#{Rails.env}"
  }

  # How to send email
  config.action_mailer.delivery_method = :mailgun 
  config.action_mailer.mailgun_settings = { 
    api_key: Figaro.env.mailgun_api_key!, 
    domain: Figaro.env.mailgun_domain!
  }

  # URL Options
  options = {
    :protocol => 'https',
    :host => Figaro.env.routes_host!,
  }
  Rails.application.routes.default_url_options = options
  config.action_mailer.asset_host = "#{"#{options[:protocol]}://" if options.has_key?(:protocol)}#{options[:host]}#{":#{options[:port]}" if options.has_key?(:port)}"

  # Whether to dump (or not) the schema after performing migrations
  config.active_record.dump_schema_after_migration = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
end

ActiveSupport::Deprecation.silenced = true
ActionController::Parameters.action_on_unpermitted_parameters = :raise
