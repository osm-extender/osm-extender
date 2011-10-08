source 'http://rubygems.org'

gem 'rails', '3.1.0'

gem 'rack', '1.3.3'

gem 'sorcery'

gem 'therubyracer'

gem 'jquery-rails'

#gem 'composite_primary_keys'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'


group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'cucumber-rails'
  gem 'webrat'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'sqlite3'
end


group :test do
  # Test coverage reports
  gem 'simplecov', '>=0.3.8', :require=>false

  # Pretty printed test output
  gem 'turn', :require => false
end


group :staging do
  gem 'activerecord-postgresql-adapter'
end


group :production do
  # Use unicorn as the web server
  # gem 'unicorn'
end