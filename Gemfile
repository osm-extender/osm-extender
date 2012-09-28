source 'http://rubygems.org'
#source 'http://production.cf.rubygems.org'  # Workaround for rubygems being down

gem 'rails', '~> 3.2'
gem 'activesupport', '~> 3.2'
gem 'actionmailer', '~> 3.2'

# Authentication / Authorisation
gem 'sorcery', '~> 0.7'
gem 'cancan', '~> 1.6'

# Javascript
gem 'therubyracer', '~> 0.10'
gem 'jquery-rails', '~> 2.1'
gem 'jquery-ui-rails', '~> 2.0'
gem 'client_side_validations', '~> 3.1'

# Misc
gem 'osm', '= 0.0.25'            # For using the OSM API
gem 'httparty', '~> 0.9'         # Used by OSM::API to make requests
gem 'recaptcha', '~> 0.3'
gem 'redcarpet', '~> 2.1'        # Used to format FAQ Answers
gem 'will_paginate', '~> 3.0'
gem 'premailer-rails3', '~> 1.3' # Used to easily generate HTML emails (also does plain text counterpart)
gem 'faker', '~> 1.1'            # Used to generate fake data for sample emails
gem 'seed-fu', '~> 2.2'          # Used to seed the database when data may change
gem 'acts_as_list', '~> 0.1'     # Makes lists of items orderable

# Jobs in background
gem 'daemons', '~> 1.1'
gem 'delayed_job_active_record', '~> 0.3'
gem 'daemon-spawn', '~> 0.4'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.0'
  gem 'coffee-rails', '~> 3.2.0'
  gem 'uglifier', '~> 1.3'
end

group :development do
  gem 'letter_opener', '~> 0.0' # Don't deliver emails, open them in a new browser window instead
end

group :development, :test do
  gem 'sqlite3', '~> 1.3'       # Use the SQLite database
end


group :staging, :production do
  gem 'mysql', '~> 2.8'         # Use a mysql database
  gem 'unicorn', '~> 4.3'       # Use unicorn as the web server
  gem 'memcache-client'
end


group :test do
  gem 'rspec-rails', '~> 2.11'
  gem 'factory_girl', '~> 4.1'
  gem 'cucumber-rails', '~> 1.3'
  gem 'webrat', '~> 0.7'
  gem 'email_spec', '~> 1.2'
  gem 'database_cleaner', '~> 0.8'
  gem 'minitest', '~> 3.5'
  gem 'simplecov', '~> 0.6', :require=>false
  gem 'turn', '~> 0.9', :require => false
  gem 'fakeweb', '~> 1.3'
  gem 'timecop', '~> 0.5'
end


# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
