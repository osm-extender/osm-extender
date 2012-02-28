namespace :ci do

  desc "Run the Travis CI tests"
  task :travis do
    # Setup files
    database_yml = File.join(Rails.root, 'config', 'database.yml')
    database_yml_example = File.join(Rails.root, 'config', 'database.yml.example')
    FileUtils.copy(database_yml_example, database_yml) unless File.exists?(database_yml)
    
    # Run commands
    ["bundle exec cucumber"].each do |cmd|
      puts "Running #{cmd}:"
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
  end

end

task :travis => "ci:travis"