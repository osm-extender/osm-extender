namespace :ci do

  desc "Run the Travis CI tests"
  task :travis do
    puts "Setting things up"
    Rake::Task['ci:travis:setup'].invoke

    puts "Checking that assets comiple"
    Rake::Task['assets:precompile'].invoke

    puts "Runnung tests"
    Rake::Task['ci:travis:tests'].invoke

    if ENV['TRAVIS']
      puts "Sending results to coveralls"
      Coveralls.push!
    end
  end

  namespace :travis do
    task :setup do
      # Setup environment
      puts "Copy database.yml.example to database.yml"
      database_yml = File.join(Rails.root, 'config', 'database.yml')
      database_yml_example = File.join(Rails.root, 'config', 'database.yml.example')
      FileUtils.copy(database_yml_example, database_yml) unless File.exists?(database_yml)

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
        puts "#{command.ljust(10, '.')}#{return_value.eql?(0) ? 'OK' : return_value.exitstatus}"
      end
      unless return_values.find{ |i| i != 0 }.nil?
        failed_commands = []
        return_values.each_with_index do |value, index|
          failed_commands.push commands[index] unless value.eql?(0)
        end
        puts "#{failed_commands.size} #{'command'.pluralize(failed_commands.size)} failed! - #{failed_commands.to_sentence}"
        raise "Something failed"
      end
    end

  end
end

