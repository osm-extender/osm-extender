class LongRunningReport
  def self.data_for?(*attrs, **opts)
    Rails.cache.exist?(cache_key(*attrs, **opts))
  end

  def self.data_for(*attrs, **opts)
    Rails.cache.fetch(cache_key(*attrs, **opts), expires_in: 10.minutes) do
      begin
        fetch_data *attrs, **opts
      rescue Osm::Error, Errno::ENETUNREACH => e
        e.instance_eval() { @__better_errors_bindings_stack = [] }
        e
      end
    end
  end
end
