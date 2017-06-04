class Status

  def unicorn_workers
    pid_file = File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')
    `pgrep -cP #{IO.read(pid_file)}`.to_i
  end

  def total_sessions
    Session.count
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
    #tables = ActiveRecord::Base.connection.tables - ['schema_migrations']
    tables = ActiveRecord::Base.connection.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")
    tables.map{ |t| t['tablename'] }.each do |table|
      next if ['schema_migrations', 'migration_validators'].include?(table)
      sql = "SELECT pg_total_relation_size('#{table}') AS size, COUNT(#{table}) AS count FROM #{table};"
      res = ActiveRecord::Base.connection.execute(sql).first
      #sizes[table.classify.constantize] = res.first['pg_total_relation_size']
      sizes.push res.symbolize_keys.merge(model: table.classify, table: table)
    end
    sizes
  end

  private
  def cache_info
    @cache_info ||= Rails.cache.data.info
  end

end
