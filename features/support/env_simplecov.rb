# Generate test coverage report
require 'simplecov'
SimpleCov.coverage_dir(File.join('tmp', 'coverage', 'cucumber'))
SimpleCov.start 'rails'
