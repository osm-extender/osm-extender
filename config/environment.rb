# Load the rails application
require File.expand_path('../application', __FILE__)

# Load custom configuration
require File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb") if File.exists?(File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb"))

# Initialize the rails application
OSMExtender::Application.initialize!
