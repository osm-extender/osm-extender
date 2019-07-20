require 'rack/request'

class FilterAppleIcons
  FILTER = %w[
    /apple-touch-icon.png
    /apple-touch-icon-precomposed.png
    /apple-touch-icon-120x120.png
    /apple-touch-icon-120x120-precomposed.png
    /apple-touch-icon-152x152.png
    /apple-touch-icon-152x152-precomposed.png
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) if FILTER.exclude?(request.path)

    Rails.logger.debug "FilterAppleIcons activated for \"#{request.path}\""
    [404, {}, []]
  end
end
