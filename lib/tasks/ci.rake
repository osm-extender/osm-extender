namespace :ci do

  desc "Run the Travis CI tests"
  task :travis do
    ["bundle exec cucumber"].each do |cmd|
      puts "Running #{cmd}:"
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
  end

end

task :travis => "ci:travis"