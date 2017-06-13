class Status

  def all
    {
      unicorn_workers: unicorn_workers,
      cache: cache,
      database_size: database_size,
      users: users,
      sessions: sessions
    }
  end


  def unicorn_workers
    return @unicorn_workers unless @unicorn_workers.nil?
    pid_file = File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')
    `pgrep -cP #{IO.read(pid_file)}`.to_i
  end


  def cache
    return @cache unless @cache.nil?
    redis = Rails.cache.data
    info = redis.info
    @cache = {
      ram_max: redis.config(:get, 'maxmemory')['maxmemory'].to_i,
      ram_used: info['used_memory'].to_i,
      keys: redis.dbsize,
      cache_hits: info['keyspace_hits'].to_i,
      cache_misses: info['keyspace_misses'].to_i,
      cache_attempts: info['keyspace_hits'].to_i + info['keyspace_misses'].to_i
    }
  end


  def database_size
    return @database_size unless @database_size.nil?
    sizes = []
    totals = {count: 0, size: 0}
    tables = ActiveRecord::Base.connection.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")
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
    @sessions ||= {
      guests: Session.guests.count,
      users: Session.users.count,
      total: Session.count,
      oldest: Session.first,
      newest: Session.last
    }
  end

end
