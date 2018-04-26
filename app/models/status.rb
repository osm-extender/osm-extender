class Status
  @@commit ||= `git --no-pager show --no-patch --format='%H - %s'`.chomp

  def unicorn_workers
    return @unicorn_workers unless @unicorn_workers.nil?
    begin
      pid_file = File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')
      pid = IO.read(pid_file)
      @unicorn_workers = `pgrep -cP #{pid}`.to_i
    rescue Errno::ENOENT
      return 0
    end
  end


  def cache
    return @cache unless @cache.nil?
    redis = Rails.cache.data
    info = redis.info
    cache_attempts = info['keyspace_hits'].to_i + info['keyspace_misses'].to_i
    @cache = {
      ram_max: redis.config(:get, 'maxmemory')['maxmemory'].to_i,
      ram_used: info['used_memory'].to_i,
      keys: redis.dbsize,
      cache_hits: info['keyspace_hits'].to_i,
      cache_hits_percent: cache_attempts.eql?(0) ? 0 : (100 * info['keyspace_hits'].to_f / cache_attempts),
      cache_misses: info['keyspace_misses'].to_i,
      cache_misses_percent: cache_attempts.eql?(0) ? 0 : (100 * info['keyspace_misses'].to_f / cache_attempts),
      cache_attempts: cache_attempts
    }
  end

  def commit
    details = @@commit.split(' - ', 2)
    {
      id: details[0],
      title: details[1]
    }
  end

  def database_size
    return @database_size unless @database_size.nil?
    schemas = (Rails.configuration.database_configuration[Rails.env]['schema_search_path'] || 'public').split(',')
    sizes = []
    totals = {count: 0, size: 0}
    tables = ActiveRecord::Base.connection.execute("SELECT tablename FROM pg_tables WHERE schemaname IN (#{schemas.map{ |s| "'#{s.strip}'" }.join(',') }) ORDER BY tablename;")
    tables.map{ |t| t['tablename'] }.each do |table|
      sql = "SELECT pg_total_relation_size('#{table}') AS size, COUNT(#{table}) AS count FROM #{table};"
      res = ActiveRecord::Base.connection.execute(sql).first
      table = {model: table.classify, table: table, size: res['size'].to_i, count: res['count'].to_i}
      sizes.push table
      totals[:count] += table[:count]
      totals[:size] += table[:size]
    end
    @database_size = {
      tables: sizes,
      totals: totals
    }
  end

  def delayed_job
    return @delayed_job unless @delayed_job.nil?

    wanted_settings = [:default_priority, :max_attempts, :max_run_time, :sleep_delay, :destroy_failed_jobs, :delay_jobs]
    settings = Hash[ wanted_settings.map{ |i| [i, Delayed::Worker.send(i)] } ]

    @delayed_job = {
      settings: settings,
      jobs: {
        total: Delayed::Job.count,
        locked: Delayed::Job.where.not(locked_at: nil).count,
        failed: Delayed::Job.where.not(failed_at: nil).count,
      }
    }
  end

  def users
    @users ||= {
      unactivated: User.unactivated.count,
      activated: User.activated.not_connected_to_osm.count,
      connected: User.activated.connected_to_osm.count,
      total: User.count
    }
  end

end
