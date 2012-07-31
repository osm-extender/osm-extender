source 'http://rubygems.org'
#source 'http://production.cf.rubygems.org'  # Workaround for rubygems being down

gem 'rails', '>=3.2.5'
gem 'activesupport', '>= 3.2'
gem 'actionmailer'

# Authentication / Authorisation
gem 'sorcery'
gem 'cancan'

# Javascript
gem 'therubyracer'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'client_side_validations'

# Misc
gem 'osm', '>= 0.0.5' # For using the OSM API
gem 'httparty'      # Used by OSM::API to make requests
gem 'recaptcha'
gem 'redcarpet'     # Used to format FAQ Answers
gem 'will_paginate'
gem 'premailer-rails3'  # Used to easily generate HTML emails (also does plain text counterpart)
gem 'faker'         # Used to generate fake data for sample emails
gem 'seed-fu'       # Used to seed the database when data may change
gem 'acts_as_list'  # Makes lists of items orderable


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'#, "  ~> 3.1.0"
  gem 'coffee-rails'#, "~> 3.1.0"
  gem 'uglifier'
end

group :development do
  gem 'letter_opener' # Don't deliver emails, open them in a new browser window instead
end

group :development, :test do
  gem 'sqlite3'   # Use the SQLite database
end


group :staging, :production do
  gem 'mysql'     # Use a mysql database
  gem 'unicorn'   # Use unicorn as the web server
  gem 'memcache-client'
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
