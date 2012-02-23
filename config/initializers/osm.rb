ActionDispatch::Callbacks.to_prepare do
  OSM::API.configure(
    # The API ID for connecting to OSM/OGM
    :api_id     => ENV["osmx_osm_id_#{Rails.env}"] || ENV['osmx_osm_id'] || ENV['osm_id'],
    # The API token for connecting to OSM/OGM
    :api_token  => ENV["osmx_osm_token_#{Rails.env}"] || ENV['osmx_osm_token'] || ENV['osm_token'],
    # The name displayed for this API on OSM/OGM's External Access page
    :api_name   => 'Aberdeen SAS - OSM Extender',
    # Use OSM (set to :scout) or OGM (set to :guide)
    :api_site   => :scout,
  )
end