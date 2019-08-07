class FilterWordpress
  FILTER = [
    %r{\A/wp-login},
    %r{\A/wp/}
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) if FILTER.none? { |pattern| request.path.match?(pattern) }

    Rails.logger.debug "FilterWordpress activated for \"#{request.path}\""
    [404, {}, []]
  end
end
