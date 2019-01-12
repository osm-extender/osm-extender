Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Configure static asset server for development with Cache-Control for performance.
  config.serve_static_files = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Setup cache
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, Rails.application.config_for(:redis)
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{2.days.to_i}"
  }

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  # if Rails.root.join('tmp', 'caching-dev.txt').exist?
  #   config.action_controller.perform_caching = true
  #   config.cache_store = :memory_store
  #   config.public_file_server.headers = {
  #     'Cache-Control' => "public, max-age=#{2.days.to_i}"
  #   }
  # else
  #   config.action_controller.perform_caching = false
  #   config.cache_store = :null_store
  # end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # What will manage the jobs on the queue for active_job
  config.active_job.queue_adapter = :delayed_job

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

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

  # Don't compress assets
  config.assets.compress = false

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Don't deliver emails, open them in a new browser window instead
  # unless mailgun_api_key env var is present
  if Figaro.env.mailgun_api_key?
    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = Rails.application.config_for(:mailgun)
  else
    config.action_mailer.delivery_method = :letter_opener
  end

  # URL options
  Rails.application.routes.default_url_options = {
    :protocol => 'http',
    :host => 'localhost',
    :port => 3000,
  }
  config.action_mailer.asset_host = 'http://localhost:3000'
  
  # Mailer email address options
  ContactUsMailer.send :default, {
    :to => 'contactus@example.com',     # Can be in the format - "Name" <email@domain.com>
  }

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Whether to dump (or not) the schema after performing migrations
  config.active_record.dump_schema_after_migration = true

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
