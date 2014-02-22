# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :osm_userid, :osm_secret, :confirmation_code, :auth_code]
