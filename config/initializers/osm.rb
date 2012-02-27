if SettingValue.table_exists? && !Settings.read('OSM API - id').nil?
  ActionDispatch::Callbacks.to_prepare do
    OSM::API.configure(
      :api_id     => Settings.read('OSM API - id'),
      :api_token  => Settings.read('OSM API - token'),
      :api_name   => Settings.read('OSM API - name'),
      :api_site   => :scout,
    )
  end
end
