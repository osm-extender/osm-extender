bind ENV.fetch('BIND', "tcp://#{ENV.fetch('HOST', '127.0.0.1')}:#{ENV.fetch('PORT', 3000)}")
threads 2, 2
workers 2
preload_app!
GC.copy_on_write_friendly = true if GC.respond_to?('copy_on_write_friendly=')
PumaWorkerKiller.config do |config|
  config.ram = 341 # MiB
  config.percent_usage = 1
  config.frequency = 5 # seconds
  config.reaper_status_logs = false
end
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  # Redis.connect if defined?(Redis)
end
on_worker_fork do    
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  Redis.current.disconnect! if defined?(Redis)
end
before_fork do
  PumaWorkerKiller.start
end
plugin :tmp_restart
