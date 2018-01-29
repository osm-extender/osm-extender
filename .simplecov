SimpleCov.coverage_dir(File.join('tmp', 'coverage'))
SimpleCov.merge_timeout 900 # Quarter of an hour
SimpleCov.add_filter 'vendor/'
SimpleCov.formatter = ENV['TRAVIS'] ? Coveralls::SimpleCov::Formatter : SimpleCov::Formatter::HTMLFormatter
