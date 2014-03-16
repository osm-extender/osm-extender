# Generate test coverage report
if Gem::Specification::find_all_by_name('simplecov').any?
  SimpleCov.coverage_dir(File.join('tmp', 'coverage'))
  SimpleCov.start 'rails' do
    add_filter 'features/'
    add_filter 'config/'
  end

  require 'coveralls' and Coveralls.wear_merged!('rails') if ENV['TRAVIS']
end

