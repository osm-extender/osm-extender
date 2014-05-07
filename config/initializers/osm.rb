ActionDispatch::Callbacks.to_prepare do
  unless Rails.env.test?
    Osm::configure(
      :api => {
        :default_site => :osm,
        :osm => {
          :id    => Rails.application.secrets.osm_api[:id],
          :token => Rails.application.secrets.osm_api[:token],
          :name  => Rails.application.secrets.osm_api[:name],
        },
        :debug => Rails.env.development?,
      },
      :cache => {
        :cache  => Rails.cache,
        :ttl    => Rails.env.development? ? 60 : 600
      },
    )

  else
    Osm::configure(
      :api => {
        :default_site => :osm,
        :osm => {
          :id    => 12,
          :token => '1234567890',
          :name  => 'Test API',
        },
        :debug => false,
      },
      :cache => {
        :cache  => Rails.cache,
        :ttl    => 30
      },
    )

  end
end
