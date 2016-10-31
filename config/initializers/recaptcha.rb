ActionDispatch::Callbacks.to_prepare do
  Recaptcha.configure do |config|
    config.public_key  = Figaro.env.recaptcha_public_key!
    config.private_key = Figaro.env.recaptcha_private_key!
  end
end

