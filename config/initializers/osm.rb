ActionDispatch::Callbacks.to_prepare do
  OSM::API.configure(
    :api_id     => ENV["osmx_osm_id_#{Rails.env}"] || ENV['osmx_osm_id'] || ENV['osm_id'],
    :api_token  => ENV["osmx_osm_token_#{Rails.env}"] || ENV['osmx_osm_token'] || ENV['osm_token'],
    :api_site   => :scout,
  )
end