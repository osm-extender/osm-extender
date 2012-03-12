ActionDispatch::Callbacks.to_prepare do
  if SettingValue.table_exists?
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
end

ActionMailer::Base.default_url_options[:host] = Rails.configuration.root_url
