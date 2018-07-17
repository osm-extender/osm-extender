namespace :app do

  task :deploy => ['db:migrate', 'deploy:rollbar']

end
