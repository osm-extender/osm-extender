namespace :ci do

  desc "Run the Travis CI tests"
  task :travis do
    # Setup environment
    puts "Copy database.yml.example to database.yml"
    database_yml = File.join(Rails.root, 'config', 'database.yml')
    database_yml_example = File.join(Rails.root, 'config', 'database.yml.example')
    FileUtils.copy(database_yml_example, database_yml) unless File.exists?(database_yml)

    puts "Setting up database"
    ['db:create', 'db:migrate', 'db:seed', 'db:seed'].each do |task|
      Rake::Task[task].reenable
      Rake::Task[task].invoke
    end
    # db:seed is run twice to ensure the seeding process plays nicely on a db with existing data


    # Run commands
    ["bundle exec cucumber"].each do |cmd|
      puts "Running #{cmd}:"
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
  end

end

task :travis => "ci:travis"