bind ENV.fetch('BIND', "tcp://#{ENV.fetch('HOST', '127.0.0.1')}:#{ENV.fetch('PORT', 3000)}")
threads 2, 2
workers 2
preload_app!
GC.copy_on_write_friendly = true if GC.respond_to?('copy_on_write_friendly=')
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  # Redis.connect if defined?(Redis)
end
on_worker_fork do    
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  Redis.current.disconnect! if defined?(Redis)
end
plugin :tmp_restart
