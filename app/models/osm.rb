module OSM

  class API

    # Initialize a new API connection
    # If passing user details then both must be passed
    # @param userid (optional) osm userid of the user to act as
    # @param secret (optional) osm secret of the user to act as
    def initialize(userid=nil, secret=nil)
      raise ArgumentError, 'You must pass a secret if you are passing a userid' if secret.nil? && !userid.nil?
      raise ArgumentError, 'You must pass a userid if you are passing a secret' if userid.nil? && !secret.nil?

      @base_url = 'https://www.onlinescoutmanager.co.uk'
      set_user(userid, secret)
    end

    # Set the OSM user to make future requests as
    # @param userid the OSM userid to use (get this using the authorize method)
    # @param secret the OSM secret to use (get this using the authorize method)
    def set_user(userid, secret)
      @userid = userid
      @secret = secret
    end

    # Configure the API options used by all instances of the class
    # @param options - a hash containing the following keys:
    #   * :api_id - the apiid given to you for using the OSM id
    #   * :api_token - the token which goes with the above api
    def self.configure(options)
      raise ArgumentError, ':api_id does not exist in options hash' if options[:api_id].nil?
      raise ArgumentError, ':api_token does not exist in options hash' if options[:api_token].nil?

      @@api_id = options[:api_id]
      @@api_token = options[:api_token]
    end

    # Get the userid and secret to be able to act as a certain user on the OSM system
    # @param email the login email address of the user on OSM
    # @param password the login password of the user on OSM
    # @returns a hash containing the following keys:
    #   * :error - true or false depending on if an HTTP error occured
    #   * :response - what HTTParty returned when making the request
    #   * :data - the parsed JSON returned by the request (only if :error is false) this is a hash containing the following keys:
    #     * 'userid' - the userid to use in future requests
    #     * 'secret' - the secret to use in future requests
    def authorize(email, password)
      data = {
        'email' => email,
        'password' => password,
      }
      perform_query('users.php?action=authorise', data)
    end


    private
    # Make the query to the OSM API
    # @param url the script on the remote server to invoke
    # @param data (optional) a hash containing the values to be sent to the server
    # @returns a hash with the following keys:
    #   * :error - true or false depending on if an HTTP error occured
    #   * :response - what HTTParty returned when making the request
    #   * :data - the parsed JSON returned by the request (only if :error is false)
    def perform_query(url, data={})
      data['apiid'] = @@api_id
      data['token'] = @@api_token

      if (data['userid'].nil? || data['secret'].nil?)
        unless (@userid.nil? || @secret.nil?)
          data['userid'] = @userid
          data['secret'] = @secret
        end
      end

      result = HTTParty.post("#{@base_url}/#{url}", {:body => data})
      to_return = {
        :error => !result.response.code.eql?('200'),
        :response => result,
      }
      to_return[:data] = ActiveSupport::JSON.decode(result.response.body) unless to_return[:error]
      return to_return
    end
  end

end
