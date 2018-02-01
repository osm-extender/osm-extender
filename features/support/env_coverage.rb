# Generate test coverage report
require 'coveralls'
require 'simplecov'
SimpleCov.command_name 'cucumber'
if ENV['TRAVIS']
  Coveralls.wear_merged! 'rails'
else
  SimpleCov.start 'rails'
end
