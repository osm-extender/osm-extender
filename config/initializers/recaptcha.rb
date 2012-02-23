if SettingValue.table_exists?
  ActionDispatch::Callbacks.to_prepare do
    Recaptcha.configure do |config|
      config.public_key  = Settings.read('ReCAPTCHA - public key')
      config.private_key = Settings.read('ReCAPTCHA - private key')
    end
  end
end
