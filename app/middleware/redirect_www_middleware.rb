require 'rack/request'

class RedirectWwwMiddleware

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) unless redirect?(request)

    location = redirect_to(request)
    content = "Please go to\n#{location}\n"
    headers = {
      'Location' => location,
      'Content-Type' => 'text/plain',
      'Content-Length' => content.length
    }
    [307, headers, [content]]
  end


  private

  def redirect?(request)
    request.host.downcase[0..3].eql?('www.')
  end

  def redirect_to(request)
    uri = URI(request.url)
    uri.host = uri.host[4..-1]
    uri.to_s
  end

end
