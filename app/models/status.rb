class Status

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


  def users
    @users ||= {
      unactivated: User.unactivated.count,
      activated: User.activated.not_connected_to_osm.count,
      connected: User.activated.connected_to_osm.count,
      total: User.count
    }
  end


  def sessions
    return @sessions unless @session.nil?

    totals = {
      all: Session.count,
      users: Session.users.count,
      guests: Session.guests.count,
    }

    average_ages = {all: 0, users: 0, guests: 0}
    average_durations = {all: 0, users: 0, guests: 0}
    # Populate average hashes with totals - we'll divide them later
    Session.pluck(:user_id, :created_at, :updated_at).each_with_object(Hash.new(0)) do |(user_id, created_at, updated_at), hash|
      user_type = user_id ? :users : :guests
      age = Time.now.to_i - created_at.to_i
      duration = updated_at.to_i - created_at.to_i
      average_ages[:all] += age
      average_ages[user_type] += age
      average_durations[:all] += duration
      average_durations[user_type] += duration
    end
    average_ages.each_key { |key| average_ages[key] /= totals[key] unless totals[key].eql?(0) } # turn the gathered sums into an average
    average_durations.each_key { |key| average_durations[key] /= totals[key] unless totals[key].eql?(0) } # turn the gathered sums into an average

    @sessions = {
      totals: totals,
      average_ages: average_ages,
      average_durations: average_durations,
      oldest: Session.first,
      newest: Session.last
    }
  end

end
