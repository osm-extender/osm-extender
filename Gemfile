source 'https://rubygems.org'
ruby File.read(File.join(__dir__, '.ruby-version')).chomp

# Rails
gem 'rails', '~> 5.2', '>= 5.2.2.1'
# gem 'activerecord-session_store', '~> 1.0'
# gem 'rb-readline'
gem 'responders', '~> 2.0'

# Authentication / Authorisation
gem 'sorcery', '~> 0.11'
#gem 'cancan', '~> 1.6'
gem 'cancan', path: File.join(File.dirname(__FILE__), '/vendor/gems/cancan-1.6.10.rob')

# Services used
gem 'redis' , '~> 4.1'
gem 'pg', '~> 1.1'                      # Use a postgresql database

# Misc
gem 'osm', '~> 1.3', '>= 1.3.6'       # For using the OSM API
#gem 'osm', :path => '../../osm/osm-code'
gem 'recaptcha', '~> 4.0', require: 'recaptcha/rails'   # Used to confirm non-logged in users are human (i.e. on contact form)
gem 'redcarpet', '~> 3.0'             # Format FAQ Answers, Announcements etc.
gem 'will_paginate', '~> 3.0'         # Paginate big index pages (e.g. Users)
gem 'premailer-rails', '~> 1.9'       # Easily generate HTML emails (also does plain text counterpart)
  gem 'nokogiri', '~> 1.10' # Adapter for premailer
gem 'mailgun-ruby', '~>1.1.6'         # Send emails through mailgun
gem 'faker', '~> 1.1'                 # Generate fake data for sample emails
gem 'acts_as_list', '~> 0.9.17'       # Makes lists of items orderable
gem 'paper_trail', '~> 10.1'          # Track changes to (selected) models
gem 'html5_validators', '~> 1.0'      # Client side validation
gem 'date_time_attribute', '~> 0.1.0' # Allow splitting datetime attributes to a date field and a time field
gem 'icalendar', '~> 2.2'             # Do stuff with ICS format files
gem 'mimemagic', '~> 0.3.2'           # Get type of image file returned by OSM
gem 'figaro', '~> 1.1'                # Use config/application.yml to hold environment variables for easier testing/development
gem 'terminal-table', '~> 1.8'        # Display data in an ASCII table

# Jobs in background
gem 'delayed_job_active_record', '~> 4.0'
gem 'delayed_cron_job', '~> 0.7'
gem 'daemons', '~> 1.3'
#gem 'daemon-spawn', '~> 0.4'

# Javascript / Assets
gem 'jquery-rails', '~> 4.0', '>= 4.0.4'
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'
gem 'jquery-tablesorter', '~> 1.23'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.0'
gem 'uglifier', '~> 4.0'
gem 'normalize-rails', '~> 4.1'
gem 'js_cookie_rails', '~> 2.1'

group :development do
  gem 'letter_opener', '~> 1.0'       # Don't deliver emails, open them in a new browser window instead
  gem 'rack-mini-profiler', '~> 0.9'  # See how long a request takes and why
  gem 'better_errors', '~> 2.0'       # See nicer exception pages with more useful information
  gem 'binding_of_caller'#, '~> 0.6'  # Allow better_errors advaced features (REPL, local/instance variable inspection, pretty stack frame names)
  gem 'pry', '~> 0.9', require: false # Nicer console to work in
  gem 'meta_request', '~> 0.6.0'      # Allow use of the rails panel Chrome extension (https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg)
#  gem 'pry-debugger', '~> 0.2', :require=>false  # Add debugging extras to pry
#  gem 'debugger', '~> 1.6', :require=>false
  gem 'bundle-audit', '~> 0.1.0'      # Scan bundle for insecure gems
  gem 'listen', '~> 3.1'
end

# Puma webserver
gem 'puma', '~> 3.12'                # Use puma as the web server
gem 'puma-rails', '~> 0.0.2'         # rails server command will use puma by default
gem 'puma_worker_killer', '~> 0.1.0' # Manage RAM growth by performing rolling restarts

group :test do
  gem 'rspec-rails', '~> 3.1'
  gem 'factory_bot', '~> 4.8'
  gem 'cucumber-rails', '~> 1.6', require: false
  gem 'webrat', '~> 0.7'
  gem 'email_spec', '~> 2.0'
  gem 'database_cleaner', '~> 1.0'
  # gem 'fakeweb', '~> 1.3', '> 1.3.0'
  gem 'fakeweb', path: File.join(File.dirname(__FILE__), '/vendor/gems/fakeweb-1.3.1.rob')
  gem 'timecop', '~> 0.5'
  gem 'turn', '~> 0.9', require: false
  gem 'rails-controller-testing', '~> 1.0'
  gem 'coveralls', '~> 0.8', require: false
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0' 
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'spring-commands-cucumber', '~> 1.0'
end

# Error Reporting
gem 'rollbar', '~> 2.16'

# Deploy with Capistrano
# gem 'capistrano'

gem 'haml-rails', '~> 1.0'

gem 'tty-prompt', '~> 0.16.0', require: false
gem 'tzinfo-data', '~> 1.2018'

# Performance reporting
group :production do
  gem 'scout_apm', '~> 2.4'
end

gem 'parallel', '~> 1.17'
