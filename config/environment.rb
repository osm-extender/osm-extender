# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
OSMExtender::Application.initialize!

# Load custom configuration
require File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb") if File.exists?(File.join(Rails.root, 'config', 'environments', "#{Rails.env}_custom.rb"))
