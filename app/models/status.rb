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


  private
  def cache_info
    @cache_info ||= Rails.cache.data.info
  end

end
