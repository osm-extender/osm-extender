OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Allow pass debug_assets=true as a query parameter to load pages with unpackaged assets
  config.assets.allow_debugging = true


  # Which sort of cache to use
  config.cache_store = :null_store  # Turn off caching

  # URL Options
  Rails.application.routes.default_url_options = {
    :protocol => 'http',
    :host => 'test',
  }

#  # Controller URL options
#  config.action_controller.default_url_options = {
#    :protocol => 'http',
#    :host => 'test',
#  }
##  ActionController::Base.default_url_options = config.action_controller.default_url_options

  # Mailer URL options
#  config.action_mailer.default_url_options = {
#    :protocol => 'http',
#    :host => 'test',
#  }
##  ActionMailer::Base.send('default_url_options=', config.action_mailer.default_url_options)

  # Mailer options
  ActionMailer::Base.send :default, {
    :from => '"OSMX" <osmx@localhost>', # Can be in the format - "Name" <email_address>
    'return-path' => 'osmx@localhost',  # Should be the email address portion of from
  }
  NotifierMailer.send :default, {
    :from => 'notifier-mailer@example.com',         # Can be in the format - "Name" <email_address>
    'return-path' => 'notifier-mailer@example.com', # Should be the email address portion of from
  }
  NotifierMailer.options = {
    :contact_form__to => 'contactus@example.com',
    :reminder_failed__to => 'reminder-mailer-failed@example.com',
    :exception__to => 'exceptions@example.com',
  }
  ReminderMailer.send :default, {
    :from => 'reminder-mailer@example.com',         # Can be in the format - "Name" <email_address>
    'return-path' => 'reminder-mailer@example.com', # Should be the email address portion of from
  }
  UserMailer.send :default, {
    :from => 'user-mailer@example.com',             # Can be in the format - "Name" <email_address>
    'return-path' => 'user-mailer@example.com',     # Should be the email address portion of from
  }

end

ActionDispatch::Callbacks.to_prepare do
  # OSM options (copy/complete into development_custom.rb)
  Osm::configure(
    :api => {
      :default_site => :osm,
      :osm => {
        :id    => 12,
        :token => '1234567890',
        :name  => "Test API",
      },
      :debug   => false
    },
    :cache => {
      :cache  => Rails.cache,
      :ttl    => 30
    },
  )

  # ReCAPTCHA options (copy/complete into staging_custom.rb)
  Recaptcha.configure do |config|
    config.public_key  = '11223344556677889900'
    config.private_key = '00998877665544332211'
  end
end
