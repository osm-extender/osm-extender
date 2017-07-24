# Generate test coverage report
if Gem::Specification::find_all_by_name('simplecov').any?
  require 'simplecov'
  SimpleCov.coverage_dir(File.join('tmp', 'coverage'))
  SimpleCov.command_name 'rspec'
  SimpleCov.merge_timeout 1800 # Half an hour
  SimpleCov.start 'rails'
  require 'coveralls' and Coveralls.wear_merged!('rails') if ENV['TRAVIS']
end



ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require_relative 'support/tasks'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


# Cause an error if any spec causes a real web request
# This should both speed up tests and ensure that our tests cover all remote requests
FakeWeb.allow_net_connect = false
FakeWeb.allow_net_connect = %r[^https://coveralls.io] # Allow coveralls to report coverage

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
#  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.fixture_path = "#{Rails.root}/test/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.before(:each) do
    FakeWeb.clean_registry
    Timecop.return
  end

end
