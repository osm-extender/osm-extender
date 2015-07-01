source 'http://rubygems.org'
#source 'http://production.cf.rubygems.org'  # Workaround for rubygems being down

# Rails
gem 'rails', '~> 4.1', '>= 4.2.2'
gem 'activerecord-session_store', '~> 0.1'

# Authentication / Authorisation
gem 'sorcery', '~> 0.8', '>= 0.8.5'
gem 'cancan', '~> 1.6'


# Misc
#gem 'osm', '~> 1.2', '>= 1.2.18'       # For using the OSM API
#gem 'osm', :path => '../../osm/code'
gem 'recaptcha', '~> 0.3'             # Used to confirm non-logged in users are human (i.e. on contact form)
gem 'redcarpet', '~> 3.2.0'           # Format FAQ Answers, Announcements etc.
gem 'will_paginate', '~> 3.0'         # Paginate big index pages (e.g. Users)
gem 'premailer-rails', '~> 1.6'       # Easily generate HTML emails (also does plain text counterpart)
  gem 'nokogiri', '~> 1.5', '>= 1.6.1'# Adapter for premailer
gem 'faker', '~> 1.1'                 # Generate fake data for sample emails
gem 'acts_as_list', '~> 0.1'          # Makes lists of items orderable
gem 'paper_trail', '~> 3.0.0'         # Track changes to (selected) models
gem 'html5_validators', '~> 1.0'      # Client side validation
gem 'date_time_attribute', '~> 0.1.0' # Allow splitting datetime attributes to a date field and a time field
gem 'pry', '~> 0.9', :require=>false  # Nicer console to work in
gem 'icalendar', '~> 2.2'             # Do stuff with ICS format files


# Jobs in background
gem 'delayed_job_active_record', '~> 4.0'
gem 'daemons', '~> 1.1'
gem 'daemon-spawn', '~> 0.4'


# Javascript / Assets
gem 'therubyracer', '~> 0.12'
  gem 'libv8', '~> 3.16', '>= 3.16.14.7'
gem 'jquery-rails', '~> 4.0', '>= 4.0.4'
gem 'jquery-ui-rails', '~> 5.0', '>= 5.0.5'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.0'
gem 'uglifier', '~> 2.0'
gem 'normalize-rails', '~> 3.0'


group :development do
  gem 'letter_opener', '~> 1.0'       # Don't deliver emails, open them in a new browser window instead
  gem 'rack-mini-profiler', '~> 0.1'  # See how long a request takes and why
  gem 'better_errors', '~> 1.0'       # See nicer exception pages with more useful information
# better_errors 2.0.0 requires ruby 2
#  gem 'binding_of_caller', '~> 0.6'   # Allow better_errors advaced features (REPL, local/instance variable inspection, pretty stack frame names)
  gem 'meta_request', '~> 0.3.4'      # Allow use of the rails panel Chrome extension (https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg)
#  gem 'pry-debugger', '~> 0.2', :require=>false  # Add debugging extras to pry
#  gem 'debugger', '~> 1.6', :require=>false
end

group :development, :test do
  gem 'sqlite3', '~> 1.3'             # Use the SQLite database
  gem 'mv-sqlite', :path => File.join(File.dirname(__FILE__), 'vendor', 'gems', 'mv-sqlite-1.0.1')           # Use migration_validations
# mv-sqlite 2.0.0 requires ruby 2
  gem 'mv-core', :path => File.join(File.dirname(__FILE__), 'vendor', 'gems', 'mv-core-1.0.1') # Remove once upgraded to 2.0
end


group :staging, :production do
  gem 'unicorn', '~> 4.3'             # Use unicorn as the web server
  gem 'connection_pool', '~> 2.0'     # Allow dalli etc. to use a pool of connections
end

# Database choices (for production/staging)
group :postgres do
  gem 'pg', '~>0.18'                  # Use a postgresql database
  gem 'mv-postgresql', '~> 1.0'       # Use migration_validations
# mv-postgresql 2.0.0 requires ruby 2
end
group :mysql do
  gem 'mysql2', '~> 0.3.11'           # Use a mysql database
  gem 'mv-mysql', '~> 1.0'            # Use migration_validations
# mv-mysql 2.0.0 requires ruby 2
end

# Cache choices (for production/staging)
group :memcache do
  gem 'dalli', '~> 2.6'               # Using memcache as the cache store
  gem 'kgio', '~> 2.9'                # Give dalli a performace boost
end
group :redis do
  gem 'redis-rails', '~>4.0'          # Using redis as the cache store
end


group :test do
  gem 'rspec-rails', '~> 3.1'
  gem 'factory_girl', '~> 4.1'
  gem 'cucumber-rails', '~> 1.3'
  gem 'webrat', '~> 0.7'
  gem 'email_spec', '~> 1.2'
  gem 'database_cleaner', '~> 1.0'
  gem 'fakeweb', '~> 1.3'
  gem 'timecop', '~> 0.5'
  gem 'simplecov', '~> 0.6'
  gem 'turn', '~> 0.9', :require => false
  gem 'coveralls', '~> 0.7'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.2' 
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'spring-commands-cucumber', '~> 1.0'
end


# Deploy with Capistrano
# gem 'capistrano'
