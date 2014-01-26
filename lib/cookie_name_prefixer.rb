class CookieNamePrefixer

  def initialize(app, prefix)
    @app = app
    @prefix = prefix
    @debug = false
  end

  def call(env)
    @env = env

    rename_incoming
    (@status, @headers, @response) = @app.call(env)
    rename_outgoing

    [@status, @headers, @response]
  end


  private
  def rename_incoming
    if @env.has_key?('HTTP_COOKIE')
      @env.delete('rack.request.cookie_string')  # Force cookies header to be reread
      @env.delete('rack.request.cookie_hash')    # Force cookies header to be reread
      cookies = []
      @env['HTTP_COOKIE'].split(';').each do |cookie|
        if cookie.start_with?(@prefix)
          old_name = cookie[0..cookie.index('=')-1]
          cookie = cookie[@prefix.length..-1]
          puts "Incoming cookie \"#{old_name}\" renamed -> #{cookie}" if @debug
          cookies.push cookie
        end
      end
      @env['HTTP_COOKIE'] = cookies.join(';')
    end
  end
  
  def rename_outgoing
    cookies = []
    if @headers.has_key?('Set-Cookie')
      @headers['Set-Cookie'].split("\n").each do |cookie|
        old_name = cookie[0..cookie.index('=')-1]
        cookie = "#{@prefix}#{cookie}"
        cookies.push cookie
        puts "Outgoing cookie \"#{old_name}\" renamed -> #{cookie}" if @debug
      end
      @headers['Set-Cookie'] = cookies.join("\n")
    end
  end

end
