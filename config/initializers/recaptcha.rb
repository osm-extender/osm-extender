ActionDispatch::Callbacks.to_prepare do
  Recaptcha.configure do |config|
    config.public_key  = ENV["osmx_recaptcha_public_key_#{Rails.env}"] || ENV['osmx_recaptcha_public_key'] || ENV['recaptcha_public_key']
    config.private_key = ENV["osmx_recaptcha_private_key_#{Rails.env}"] || ENV['osmx_recaptcha_private_key'] || ENV['recaptcha_private_key']
  end
end