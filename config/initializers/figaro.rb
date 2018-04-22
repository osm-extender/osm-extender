Figaro.require_keys(
  'secret_key_base',
  'osm_api_name', 'osm_api_id', 'osm_api_token',
  'recaptcha_public_key', 'recaptcha_private_key'
)

if Rails.configuration.action_mailer.delivery_method.eql?(:mailgun)
  Figaro.require_keys(
    'mailgun_domain', 'mailgun_api_key'
  )
end
