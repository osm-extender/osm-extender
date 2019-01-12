require_relative 'boot'
require_relative '../app/middleware/redirect_www_middleware'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OSMExtender
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << Rails.root.join('lib')

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

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
      who = prompt.ask("Who should paper trail's versions credit changes to?") do |p|
        p.required true
        p.default `whoami`.chomp
        p.modify :trim
      end
      PaperTrail.request.whodunnit = "console: #{who}"
    end

    # Redirect www.... host to ...
    config.middleware.insert_before 0, RedirectWwwMiddleware

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
