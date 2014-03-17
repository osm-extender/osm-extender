ActionDispatch::Callbacks.to_prepare do
  unless Rails.env.test?
    Recaptcha.configure do |config|
      config.public_key  = Rails.application.secrets.recaptcha[:public_key]
      config.private_key = Rails.application.secrets.recaptcha[:private_key]
    end

  else
    Recaptcha.configure do |config|
      config.public_key  = '11223344556677889900'
      config.private_key = '00998877665544332211'
    end

  end
end

