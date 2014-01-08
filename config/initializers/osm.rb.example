ActionDispatch::Callbacks.to_prepare do
  if SettingValue.table_exists? && !Settings.read('OSM API - id').nil?
    Osm::configure(
      :api => {
        :default_site => :osm,
        :osm => {
          :id    => Settings.read('OSM API - id'),
          :token => Settings.read('OSM API - token'),
          :name  => Settings.read('OSM API - name'),
        },
        :debug => Rails.env.development? || defined?(IRB)
      },
      :cache => {
        :cache          => Rails.cache,
        :ttl            => Rails.env.development? ? 30 : 600
      },
    )
  end
end
