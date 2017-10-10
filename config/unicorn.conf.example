app_directory = "/var/www/rails-apps/osmx.staging"

require 'unicorn/autoscaling'

# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 2

# Perform autoscaling of workers (default false)
autoscaling true
# Minimum average idle time before decreasing number of workers (default 60)
autoscale_idle_time_decrement 30
# Maximum average idle time before increasing number of workers (default 10)
autoscale_idle_time_increment 10
# How many requests are used to calculate the average idle time (default 50)
autoscale_idle_time_samples 20
# How often to check if scaling should be performed (default 30)
autoscale_check_interval 30
# Set the minimum number of worker processes (default 1)
autoscale_min_workers 2
# Set the maximum number of worker processes (default nil)
autoscale_max_workers 4


# Since Unicorn is never exposed to outside clients, it does not need to
# run on the standard HTTP port (80), there is no reason to start Unicorn
# as root unless it's from system init scripts.
# If running the master process as root and the workers as an unprivileged
# user, do this to switch euid/egid in the workers (also chowns logs):
user "www-data", "www-data"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory app_directory # available in 0.94.0+

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
#listen "/tmp/.sock", :backlog => 64
#listen "127.0.0.1:3000"
#listen "[::1]:3000"
listen "#{app_directory}/tmp/unicorn.sock"

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# feel free to point this anywhere accessible on the filesystem
pid "#{app_directory}/tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
#stderr_path "/path/to/app/shared/log/unicorn.stderr.log"
#stdout_path "/path/to/app/shared/log/unicorn.stdout.log"
#stderr_path "#{app_directory}/log/unicorn-error.log"
stderr_path "#{app_directory}/log/unicorn.log"
stdout_path "#{app_directory}/log/unicorn.log"

# Setup Rails style logs
Configurator::DEFAULTS[:logger].formatter = Logger::Formatter.new

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  # Same for redis
  Redis.current.disconnect! if defined?(Redis)

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # # This allows a new master process to incrementally
  # # phase out the old master process with SIGTTOU to avoid a
  # # thundering herd (especially in the "preload_app false" case)
  # # when doing a transparent upgrade.  The last worker spawned
  # # will then kill off the old master process with a SIGQUIT.
  # old_pid = "#{server.config[:pid]}.oldbin"
  # if old_pid != server.pid
  #   begin
  #     sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
  #     Process.kill(sig, File.read(old_pid).to_i)
  #   rescue Errno::ENOENT, Errno::ESRCH
  #   end
  # end
  #
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
end

after_fork do |server, worker|
  # per-process PID file
  #system("echo #{Process.pid} > #{app_directory}/tmp/pids/unicorn-#{worker.nr + 1}.pid")

  # per-process listener ports for debugging/admin/migrations
  #addr = "vps01.tangyorange.co.uk:#{3011 + worker.nr}"
  #server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # The following is *required* for Rails + "preload_app true",
  # if preload_app is true, then you want restart any shared
  # sockets/descriptors such as ActiveRecord, Memcached and Redis.
  # TokyoCabinet file handles are safe to reuse between any number of forked
  # children (assuming your kernel correctly implements pread()/pwrite()
  # system calls)

  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)

 # Redis.connect if defined?(Redis)
end
