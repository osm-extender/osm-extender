bind ENV.fetch('BIND', "tcp://#{ENV.fetch('HOST', '0.0.0.0')}:#{ENV.fetch('PORT', 3000)}")

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
threads 2, 2

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
workers 2

# Specifies the `environment` that Puma will run in.
# environment ENV.fetch('RAILS_ENV', 'development')

# Configure the automatic killing of Puma workers.
PumaWorkerKiller.config do |config|
  # How much RAM must everything fit in (set this to the upper limit of the container).
  config.ram = 512 # MiB
  # At what percentage of RAM usage should somehting be done.
  config.percent_usage = 0.9
  # How often should it be checked.
  config.frequency = 10 # seconds
  # How often should rolling restarts be performed.
  config.rolling_restart_frequency = 4 * 3600 # 4 hours in seconds
  # Don't "polute" logs with the memory used every n seconds.
  config.reaper_status_logs = false
end

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
preload_app!
GC.copy_on_write_friendly = true if GC.respond_to?('copy_on_write_friendly=')

# Verifies that all workers have checked in to the master process within
# the given timeout. If not the worker process will be restarted. This is
# not a request timeout, it is to protect against a hung or dead process.
# Setting this value will not protect against slow requests.
# Default value is 60 seconds.
worker_timeout 60

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  # Redis.connect if defined?(Redis)
end

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. This code will
# be run on the master when it is about to fork a worker.
on_worker_fork do
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  Redis.current.disconnect! if defined?(Redis)
end

before_fork do
  PumaWorkerKiller.start
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
