require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec


namespace :ci do
  desc "Run the Travis CI tests"
  task :travis do
    Rake::Task[:spec].invoke
  end
end