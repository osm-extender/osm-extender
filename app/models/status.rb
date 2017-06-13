class Status

  def unicorn_workers
    pid_file = File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')
    `pgrep -cP #{IO.read(pid_file)}`.to_i
  end

  def cache_used
    cache_info['used_memory'].to_i
  end

  def cache_maximum
    Rails.cache.data.config(:get, 'maxmemory')['maxmemory'].to_i
  end

  def cache_keys
    Rails.cache.data.dbsize
  end

  def cache_hits
    cache_info['keyspace_hits'].to_i
  end

  def cache_misses
    cache_info['keyspace_misses'].to_i
  end

  def database_size
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
    {
      tables: sizes,
      totals: totals
    }
  end

  def users
    {
      pending: User.where(activation_state: 'pending').count,
      activated: User.where(activation_state: 'active', osm_userid: nil).count,
      connected: User.where(activation_state: 'active').where.not(osm_userid: nil).count,
      total: User.count
    }
  end

  def sessions
    {
      guests: Session.where(user_id: nil).count,
      users: Session.where.not(user_id: nil).count,
      total: Session.count,
      oldest: Session.first,
      newest: Session.last
    }
  end

  private
  def cache_info
    @cache_info ||= Rails.cache.data.info
  end

end
