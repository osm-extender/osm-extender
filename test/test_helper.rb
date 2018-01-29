# Generate test coverage report
require 'coveralls'
require 'simplecov'
SimpleCov.command_name 'test'
if ENV['TRAVIS']
  Coveralls.wear_merged! 'rails'
else
  SimpleCov.start 'rails'
end


# Origonal top of file
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Cause an error if any test causes a real web request
# This should both speed up tests and ensure that our tests cover all remote requests
FakeWeb.allow_net_connect = false

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
