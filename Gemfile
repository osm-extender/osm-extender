source 'http://rubygems.org'
#source 'http://production.cf.rubygems.org'  # Workaround for rubygems being down

gem 'rails', '~> 3.2', '>= 3.2.16'
gem 'actionmailer', '~> 3.2', '>= 3.2.16'

# Authentication / Authorisation
gem 'sorcery', '~> 0.8', '>= 0.8.5'
gem 'cancan', '~> 1.6'

# Javascript
gem 'therubyracer', '~> 0.12'
  gem 'libv8', '~> 3.16', '>= 3.16.14.03'
gem 'jquery-rails', '~> 3.0'
gem 'jquery-ui-rails', '~> 4.0'
gem 'client_side_validations', '~> 3.1'

# Misc
gem 'osm', '~> 1.2', '>= 1.2.4'       # For using the OSM API
#gem "osm", :path => "../../osm/code"
gem 'recaptcha', '~> 0.3'             # Used to confirm non-logged in users are human (i.e. on contact form)
gem 'redcarpet', '~> 3.0'             # Format FAQ Answers, Announcements etc.
gem 'will_paginate', '~> 3.0'         # Paginate big index pages (e.g. Users)
gem 'premailer-rails', '~> 1.6'       # Easily generate HTML emails (also does plain text counterpart)
  gem 'nokogiri', '~> 1.5', '>= 1.6.1'# Adapter for premailer
gem 'faker', '~> 1.1'                 # Generate fake data for sample emails
gem 'acts_as_list', '~> 0.1'          # Makes lists of items orderable
gem "audited-activerecord", "~> 3.0"  # Auditing of changes made to data

# Jobs in background
gem 'delayed_job_active_record', '~> 4.0'
gem 'daemons', '~> 1.1'
gem 'daemon-spawn', '~> 0.4'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.0'
  gem 'coffee-rails', '~> 3.2.0'
  gem 'uglifier', '~> 2.0'
end

group :development do
  gem 'letter_opener', '~> 1.0'       # Don't deliver emails, open them in a new browser window instead
  gem 'rack-mini-profiler', '~> 0.1'  # See how long a request takes and why
  gem 'better_errors', '~> 1.0'       # See nicer exception pages with more useful information
  gem 'binding_of_caller', '~> 0.6'   # Allow better_errors advaced features (REPL, local/instance variable inspection, pretty stack frame names)
  gem 'meta_request', '~> 0.2.2'      # Allow use of the rails panel Chrome extension (https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg)
end

group :development, :test do
  gem 'sqlite3', '~> 1.3'             # Use the SQLite database
end


group :staging, :production do
  gem 'mysql2', '~> 0.3.11'           # Use a mysql database
  gem 'unicorn', '~> 4.3'             # Use unicorn as the web server
  gem 'dalli', '~> 2.6'               # Using memcache as the cache store
end


group :test do
  gem 'rspec-rails', '~> 2.11'
  gem 'factory_girl', '~> 4.1'
  gem 'cucumber-rails', '~> 1.3'
  gem 'webrat', '~> 0.7'
  gem 'email_spec', '~> 1.2'
  gem 'database_cleaner', '~> 1.0'
  gem 'fakeweb', '~> 1.3'
  gem 'timecop', '~> 0.5'
  gem 'simplecov', '~> 0.6', :require => false
  gem 'turn', '~> 0.9', :require => false
end


# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
