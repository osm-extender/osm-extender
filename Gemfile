source 'http://rubygems.org'

gem 'rails'

#gem 'rack', '1.3.3'

gem 'activesupport', '>= 3.2'

gem 'actionmailer'

gem 'sorcery'

gem 'therubyracer'
gem 'jquery-rails'

gem 'cancan'

gem 'httparty'

gem 'recaptcha'

gem 'redcarpet'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'#, "  ~> 3.1.0"
  gem 'coffee-rails'#, "~> 3.1.0"
  gem 'uglifier'
end

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'


group :development, :test do
  gem 'sqlite3'
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


#group :staging do
#  gem 'pg'
#end


group :staging, :production do
  # Use unicorn as the web server
  gem 'unicorn'
end
