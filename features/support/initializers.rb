# Everything in this file is to make sure that the cucumber tests run as well under rake as on their own
# It appears that since the application initalizers are run before any fixtures get loaded that we'll need to
# do the work of some of them, specifically the ones which rely on the database for configuration values
# and/or the ones in an ActionDispatch::Callbacks.to_prepare block.

Before do
  Settings.setup

    Osm::configure(
      :api => {
        :default_site => :osm,
        :osm => {
          :id    => 12,
          :token => '1234567890',
          :name  => 'Test API',
        },
      },
      :cache => {
        :cache          => nil,
      },
    )

  Recaptcha.configure do |config|
    config.public_key  = Settings.read('ReCAPTCHA - public key')
    config.private_key = Settings.read('ReCAPTCHA - private key')
  end

  ActionMailer::Base.smtp_settings = {
    :address              => Settings.read('Mail Server - Address'),
    :port                 => Settings.read('Mail Server - Port'),
    :domain               => Settings.read('Mail Server - Domain'),
    :user_name            => Settings.read('Mail Server - Username'),
    :password             => Settings.read('Mail Server - Password'),
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }

end
