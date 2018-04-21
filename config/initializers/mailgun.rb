if Rails.configuration.action_mailer.delivery_method.eql?(:mailgun)
  Mailgun.configure do |config|
    config.api_key = Figaro.env.mailgun_api_key!
  end
end
  