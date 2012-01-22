module OSM


  class API

    # Initialize a new API connection
    # If passing user details then both must be passed
    # @param userid (optional) osm userid of the user to act as
    # @param secret (optional) osm secret of the user to act as
    # @param site (optional) wether to use OSM (:scout) or OGM (:guide), defaults to the value set for the class
    def initialize(userid=nil, secret=nil, site=@@api_site)
      raise ArgumentError, 'You must pass a secret if you are passing a userid' if secret.nil? && !userid.nil?
      raise ArgumentError, 'You must pass a userid if you are passing a secret' if userid.nil? && !secret.nil?
      raise ArgumentError, 'site is invalid, if passed it should be either :scout or :guide' unless [:scout, :guide].include?(site)

      @base_url = 'https://www.onlinescoutmanager.co.uk' if site == :scout
      @base_url = 'https://www.onlineguidemanager.co.uk' if site == :guide
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
    #   * :api_site - wether to use OSM (if :scout) or OGM (if :guide)
    def self.configure(options)
      raise ArgumentError, ':api_id does not exist in options hash' if options[:api_id].nil?
      raise ArgumentError, ':api_token does not exist in options hash' if options[:api_token].nil?
      raise ArgumentError, ':api_site does not exist in options hash or is invalid, this should be set to either :scout or :guide' unless [:scout, :guide].include?(options[:api_site])

      @@api_id = options[:api_id]
      @@api_token = options[:api_token]
      @@api_site = options[:api_site]
    end

    # Get the API ID used in this class
    # @returns the API ID
    def self.api_id
      return @@api_id
    end

    # Get the userid and secret to be able to act as a certain user on the OSM system
    # @param email the login email address of the user on OSM
    # @param password the login password of the user on OSM
    # @returns a hash containing the following keys:
    #   * :http_error - true or false depending on if an HTTP error occured
    #   * :osm_error - true or false depending on if an OSM error occured
    #   * :response - what HTTParty returned when making the request
    #   * :data - (only if :http_error is false and :osm_error is false) is a hash containing the following keys:
    #     * 'userid' - the userid to use in future requests
    #     * 'secret' - the secret to use in future requests
    #   * :data - (only if :http_error is false and :osm_error is true) a string containing the error message from OSM
    def authorize(email, password)
      data = {
        'email' => email,
        'password' => password,
      }
      perform_query('users.php?action=authorise', data)
    end

    # Get the user's roles
    # @param data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - true or false depending on if an HTTP error occured
    #   * :osm_error - true or false depending on if an OSM error occured
    #   * :response - what HTTParty returned when making the request
    #   * :data - (only if :http_error is false and osm_error is true) this is a string containing the error message from OSM
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::Role objects
    def get_roles(data={})
      response = perform_query('api.php?action=getUserRoles', data)

      # If sucessful make result an array of Role objects
      unless response[:http_error] || response[:osm_error]
        result = Array.new
        response[:data].each do |item|
          result.push OSM::Role.new(item)
        end
        response[:data] = result
      end

      return response
    end

    # Get API access details for a given section
    # @section_id the section to get details for
    # @param data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - true or false depending on if an HTTP error occured
    #   * :osm_error - true or false depending on if an OSM error occured
    #   * :response - what HTTParty returned when making the request
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::ApiAccess objects
    #   * :data - (only if :http_error is false and osm_error is true) this is a string containing the error message from OSM
    def get_api_access(section_id, data={})
      response = perform_query("users.php?action=getAPIAccess&sectionid=#{section_id}", data)

      # If sucessful make result an array of ApiAccess objects
      unless response[:http_error] || response[:osm_error]
        result = Array.new
        response[:data]['apis'].each do |item|
          result.push OSM::ApiAccess.new(item)
        end
        response[:data] = result
      end

      return response
    end

    # Get our API access details for a given section
    # @section_id the section to get details for
    # @param data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - true or false depending on if an HTTP error occured
    #   * :osm_error - true or false depending on if an OSM error occured
    #   * :response - what HTTParty returned when making the request
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::ApiAccess objects
    #   * :data - (only if :http_error is false and osm_error is true) this is a string containing the error message from OSM
    def get_our_api_access(section_id, data={})
      response = perform_query("users.php?action=getAPIAccess&sectionid=#{section_id}", data)

      # If sucessful make result an ApiAccess object
      found = nil
      unless response[:http_error] || response[:osm_error]
        response[:data]['apis'].each do |item|
          this_item = OSM::ApiAccess.new(item)
          found = this_item if this_item.our_api?
        end
      end
      response[:data] = found

      return response
    end


    private
    # Make the query to the OSM API
    # @param url the script on the remote server to invoke
    # @param data (optional) a hash containing the values to be sent to the server
    # @returns a hash with the following keys:
    #   * :http_error - true or false depending on if an HTTP error occured
    #   * :osm_error - true or false depending on if an OSM error occured
    #   * :response - what HTTParty returned when making the request
    #   * :data - (only if :http_error is false and osm_error is false) the parsed JSON returned by OSM
    #   * :data - (only if :http_error is false and osm_error is true) this is a string containing the error message from OSM
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
        :http_error => !result.response.code.eql?('200'),
        :osm_error => result.response.body[0..8].eql?('{"error":'),
        :response => result,
      }
      unless to_return[:http_error]
        to_return[:data] = ActiveSupport::JSON.decode(result.response.body)
        to_return[:data] = to_return[:data]['error'] if to_return[:osm_error]
      end
      return to_return
    end
  end



  class Role

    attr_reader :section, :group_name, :group_id, :group_normalized, :section_id, :section_name, :section_type, :default, :permissions

    # Initialize a new UserRole using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @section = OSM::Section.new(data['sectionid'], ActiveSupport::JSON.decode(data['sectionConfig']))
      @group_name = data['groupname']
      @group_id = data['groupid'].to_i
      @group_normalized = data['groupNormalised'].to_i
      @section_id = data['sectionid'].to_i
      @section_name = data['sectionname']
      @section_type = data['section'].to_sym
      @default = data['isDefault'].eql?('1') ? true : false
      @permissions = data['permissions'].symbolize_keys
    end

  end


  class Section

    attr_reader :id, :subscription_level, :subscription_expires, :section_type, :num_scouts, :has_badge_records, :has_programme, :wizard, :column_names, :fields, :intouch_fields, :mobile_fields, :extra_records

    # Initialize a new SectionConfig using the hash returned by the API call
    # @param id the section ID used by the API to refer to this section
    # @param data the hash of data for the object returned by the API
    def initialize(id, data)
      subscription_levels = [:bronze, :silver, :gold]
      
      @id = id.to_i
      @subscription_level = subscription_levels[data['subscription_level'] - 1]
      @subscription_expires = Date.parse(data['subscription_expires'], 'yyyy-mm-dd')
      @section_type = data['sectionType'].to_sym
      @num_scouts = data['numscouts']
      @has_badge_records = data['hasUsedBadgeRecords'].eql?('1') ? true : false
      @has_programme = data['hasProgramme']
      @wizard = data['wizard'].downcase.eql?('true') ? true : false
      @column_names = data['columnNames'].symbolize_keys
      @fields = data['fields'].symbolize_keys
      @intouch_fields = data['intouch'].symbolize_keys
      @mobile_fields = data['mobFields'].symbolize_keys
      @extra_records = data['extraRecords']

      # Symbolise the keys in each hash of the extra_records array
      @extra_records.each do |item|
        item.symbolize_keys!
      end
    end

  end


  class ApiAccess

    attr_reader :id, :name, :permissions

    # Initialize a new API Access using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['apiid']
      @name = data['name']
      @permissions = data['permissions'].symbolize_keys

      # Convert permission values to a number
      @permissions.each_key do |key|
        @permissions[key] = @permissions[key].to_i
      end

      # Determine if this API has read access for the provided permission
      # @param key - the key for the permission being queried
      # @returns - true if this API can read the passed permission, false otherwise
      def can_read?(key)
        return @permissions[key] == 10 || @permissions[key] == 20
      end

      # Determine if this API has write access for the provided permission
      # @param key - the key for the permission being queried
      # @returns - true if this API can write the passed permission, false otherwise
      def can_write?(key)
        return @permissions[key] == 20
      end

      # Determine if this API is the API being used to make requests
      # @returns - true if this is the API being used, false otherwise
      def our_api?
        return @id == OSM::API.api_id
      end

    end

  end


  private
  def self.make_array_of_symbols(array)
    array.each_with_index do |item, index|
      array[index] = item.to_sym
    end
  end

end
