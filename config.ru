# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

map Rails.application.routes.default_url_options[:script_name] || '/' do
  run OSMExtender::Application
end
