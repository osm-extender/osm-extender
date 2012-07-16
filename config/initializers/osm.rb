ActionDispatch::Callbacks.to_prepare do
  if SettingValue.table_exists? && !Settings.read('OSM API - id').nil?
    Osm::Api.configure(
      :api_id     => Settings.read('OSM API - id'),
      :api_token  => Settings.read('OSM API - token'),
      :api_name   => Settings.read('OSM API - name'),
      :api_site   => :scout,
    )
  end
end
