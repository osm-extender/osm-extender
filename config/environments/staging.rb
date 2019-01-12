Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Eager load code on boot.
  config.eager_load = true

  # Configure static asset server with Cache-Control for performance.
  config.serve_static_files = true

  # Show full error reports.
  config.consider_all_requests_local = false

  # Setup cache
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, Rails.application.config_for(:redis)
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{2.days.to_i}"
  }

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # What will manage the jobs on the queue for active_job
  config.active_job.queue_adapter = :delayed_job

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Log to STDOUT
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = Logger::Formatter.new
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  config.colorize_logging = true
  config.log_level = :debug
  STDOUT.sync = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Compress assets
  config.assets.compress = false

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true
  
  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Don't deliver emails, open them in a new browser window instead
  # unless mailgun_api_key env var is present
  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.mailgun_settings = Rails.application.config_for(:mailgun)

  # URL options
  options = {
    :protocol => 'https',
    :host => Figaro.env.routes_host!,
  }
  Rails.application.routes.default_url_options = options
  config.action_mailer.asset_host = "#{"#{options[:protocol]}://" if options.has_key?(:protocol)}#{options[:host]}#{":#{options[:port]}" if options.has_key?(:port)}"
  
  # Suppress logger output for asset requests.
  config.assets.quiet = false

  # Whether to dump (or not) the schema after performing migrations
  config.active_record.dump_schema_after_migration = false

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true
end

ActiveSupport::Deprecation.silenced = true
ActionController::Parameters.action_on_unpermitted_parameters = :raise
