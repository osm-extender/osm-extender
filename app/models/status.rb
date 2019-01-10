class Status

  def health
#    checks = []
#    health = {
#      ok: [],
#      not_ok: []
#    }
#
#    checks.each do |check|
#      key = check.ok? ? :ok : :not_ok
#      health[key].push check
#    end
#
#    health[:healthy] = health[:not_ok].none?
#    health
    {healthy: true, ok: [], not_ok: []}
  end


  def cache
    return @cache unless @cache.nil?
    redis = Rails.cache.data
    info = redis.info
    cache_attempts = info['keyspace_hits'].to_i + info['keyspace_misses'].to_i
    ram_max = begin
      redis.config(:get, 'maxmemory')['maxmemory'].to_i
    rescue Redis::CommandError
      nil
    end
    @cache = {
      ram_max: ram_max,
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
    {
      id: ENV['HEROKU_SLUG_COMMIT'] || `git --no-pager show --no-patch --format='%H'`.chomp,
      title: ENV['HEROKU_SLUG_DESCRIPTION'] || `git --no-pager show --no-patch --format='%s'`.chomp
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
        cron: Delayed::Job.where.not(cron: nil).count,
      }
    }
  end

  def scheduled_jobs
    return @scheduled_jobs unless @scheduled_jobs.nil?

    job_status = lambda do |job|
      return :running if job.locked_at
      return :failed if job.failed_at
      :success
    end

    @scheduled_jobs = Delayed::Job.where.not(cron: nil)
                                  .map do |job|
                                    {
                                      id: job.id,
                                      type: YAML.parse(job.handler)
                                                .map(&:tag)
                                                .select { |n| n&.start_with?('!ruby/object:') }
                                                .first.split(':', 2).last,
                                      status: job_status.call(job),
                                      cron: job.cron,
                                      run_at: job.run_at,
                                    }
                                  end
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
