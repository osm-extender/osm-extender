source 'http://rubygems.org'

gem 'rails'
gem 'activesupport', '>= 3.2'
gem 'actionmailer'

# Authentication / Authorisation
gem 'sorcery'
gem 'cancan'

# Javascript
gem 'therubyracer'
gem 'jquery-rails'

# Misc
gem 'httparty'    # Used by OSM::API to make requests
gem 'recaptcha'
gem 'redcarpet'   # used to format FAQ Answers


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'#, "  ~> 3.1.0"
  gem 'coffee-rails'#, "~> 3.1.0"
  gem 'uglifier'
end


group :development, :test do
  gem 'sqlite3'   # Use the SQLite database
end


group :staging, :production do
  gem 'mysql'     # Use a mysql database
  gem 'unicorn'   # Use unicorn as the web server
end


group :test do
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'cucumber-rails'
  gem 'webrat'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'minitest'
  gem 'simplecov', '>=0.3.8', :require=>false
  gem 'turn', :require => false
  gem 'fakeweb'
  gem 'timecop'
end


# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

