OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Which sort of cache to use
  config.cache_store = :memory_store, {
    :size => 8 * (1024 * 1024), #MiB
    :compress => true,
    :compress_threshold => 1 * (1024 * 1024), #MiB
    :expires_in => 30.minutes,
    :race_condition_ttl => 2.minutes
  }

  # Don't deliver emails, open them in a new window instead
  config.action_mailer.delivery_method = :letter_opener

  # URL Options
  Rails.application.routes.default_url_options = {
    :protocol => 'http',
    :host => 'localhost',
    :port => 3000,
  }
  config.action_mailer.asset_host = "#{"#{Rails.application.routes.default_url_options[:protocol]}://" if Rails.application.routes.default_url_options[:protocol]}#{Rails.application.routes.default_url_options[:host]}#{":#{Rails.application.routes.default_url_options[:port]}" if Rails.application.routes.default_url_options[:port]}"

  # Mailer email address options (you may override this in development_custom.rb)
  ActionMailer::Base.send :default, {
    :from => '"OSMX" <osmx@localhost>', # Can be in the format - "Name" <email_address>
    'return-path' => 'osmx@localhost',  # Should be the email address portion of from
  }
  NotifierMailer.options = {
    :contact_form__to => 'contactus@example.com',
    :reminder_failed__to => 'reminder-mailer-failed@example.com',
    :exception__to => 'exceptions@example.com',
  }

end

ActionController::Parameters.action_on_unpermitted_parameters = :raise


# Load custom configuration
require File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb") if File.exists?(File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb"))

