require 'unicorn/autoscaling'

user "app", "app"
working_directory Rails.root

listen '0.0.0.0:3000'
timeout 120

worker_processes 4
autoscaling true
autoscale_idle_time_decrement 30
autoscale_idle_time_increment 10
autoscale_idle_time_samples 20
autoscale_check_interval 30
autoscale_min_workers 4
autoscale_max_workers 8

pid "#{Rails.root}/tmp/pids/unicorn.pid"

Configurator::DEFAULTS[:logger].formatter = Logger::Formatter.new

preload_app true
GC.copy_on_write_friendly = true if GC.respond_to?('copy_on_write_friendly=')

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  Redis.current.disconnect! if defined?(Redis)
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
 #  Redis.connect if defined?(Redis)
end
