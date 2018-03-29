namespace :ci do

  desc "Run the Travis CI tests"
  task :travis do
    puts "Setting things up"
    require 'coveralls'
    require 'simplecov'
    Rake::Task['ci:travis:setup'].invoke

    puts "Checking that assets comiple"
    Rake::Task['assets:precompile'].invoke

    puts "Runnung tests"
    Rake::Task['ci:travis:tests'].invoke

    if ENV['TRAVIS']
      puts "Sending results to coveralls"
      SimpleCov.coverage_dir(File.join('tmp', 'coverage'))
      FakeWeb.allow_net_connect = true # Allow coveralls to report to coveralls.io
      Coveralls.push!
    end
  end

  namespace :travis do
    task :setup do
      # Setup environment
      puts "Setting up database"
      ['db:setup', 'db:migrate', 'db:seed', 'db:fixtures:load'].each do |task|
        Rake::Task[task].reenable
        Rake::Task[task].invoke
      end
      # db:seed is run twice to ensure the seeding process plays nicely on a db with existing data
    end


    task :tests do
      # Run commands
      commands = ['cucumber', 'rspec']
      return_values = []
      commands.each do |cmd|
        puts "Running #{cmd}:"
        system("export DISPLAY=:99.0 && bundle exec #{cmd}")
        return_values.push $?
      end

      puts "\nExit statuses:"
      commands.each_with_index do |command, index|
        return_value = return_values[index]
        puts "#{command.ljust(10, '.')}#{return_value.exitstatus}"
      end
      unless return_values.find{ |i| i != 0 }.nil?
        failed_commands = []
        return_values.each_with_index do |value, index|
          failed_commands.push commands[index] unless value.eql?(0)
        end
        puts "#{failed_commands.size} #{'command'.pluralize(failed_commands.size)} failed! - #{failed_commands.to_sentence}"
        fail "Something failed"
      end
    end

  end
end

