class FilterWordpress
  FILTER = %w[
    /wp-login
    /wp-login.php
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) if FILTER.exclude?(request.path)

    Rails.logger.debug "FilterWordpress activated for \"#{request.path}\""
    [404, {}, []]
  end
end
