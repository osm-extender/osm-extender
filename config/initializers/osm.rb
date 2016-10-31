ActionDispatch::Callbacks.to_prepare do
  Osm::configure(
    :api => {
      :default_site => :osm,
      :osm => {
        :id    => Figaro.env.osm_api_id!,
        :token => Figaro.env.osm_api_token!,
        :name  => Figaro.env.osm_api_name!,
      },
      :debug => Rails.env.development?,
    },
    :cache => {
      :cache  => Rails.cache,
      :ttl    => Rails.env.development? ? 60 : 600
    },
  )
end
