namespace :app do

  task :setup => ['setup:first_user', 'setup:cron_jobs']

end
