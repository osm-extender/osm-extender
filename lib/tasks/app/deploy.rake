namespace :app do

  task :deploy => ['db:migrate', 'assets:precompile', 'deploy:rollbar']

end
