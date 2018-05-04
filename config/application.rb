require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'


Bundler.require(:default, Rails.env) if defined?(Bundler)


module OSMExtender
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << "#{config.root}/lib"

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '71'

    # Ensure that the application's assets are picked up for compiling
    config.assets.precompile += ['*.js', '*.css']

    # Setup console
    console do
      # Use Pry if installed
      if Gem::Specification::find_all_by_name('pry').any?
        require 'pry'
        config.console = Pry
      end
      # Put OSM gem into debug mode
      Osm::Api.debug = true
      # Set user for paper trails audits
      require 'tty-prompt'
      prompt = TTY::Prompt.new
      who = prompt.ask("Who should paper trail's versions credit changes to?") { |p|
        p.required true
        p.default `whoami`.chomp
        p.modify :trim
      }
      PaperTrail.whodunnit = "console: #{who}"
    end

    # Redirect www.... host to ...
    config.middleware.insert_before 0, 'RedirectWwwMiddleware'

    config.active_record.raise_in_transactional_callbacks = true

  end
end
