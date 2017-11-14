worker_processes 1

timeout 30

pid "#{Rails.root}/tmp/pids/unicorn.pid"

Configurator::DEFAULTS[:logger].formatter = Logger::Formatter.new

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  Redis.current.disconnect! if defined?(Redis)
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
 #  Redis.connect if defined?(Redis)
end
