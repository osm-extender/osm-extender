module OSM


  class API

    @@default_cache_ttl = 30.minutes  # Some things will only be cached for half this time
                                      # Whereas others will be cached for twice this time
                                      # Most items however will be cached for this time

    @@user_access = Hash.new

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
    #   * :api_name - the name displayed in the External Access tab of OSM
    #   * :api_site - wether to use OSM (if :scout) or OGM (if :guide)
    #   * :default_cache_ttl (optional, default = 30 minutes) - The default TTL value for the cache, note that some items are cached for twice this time and others are cached for half this time.
    def self.configure(options)
      raise ArgumentError, ':api_id does not exist in options hash' if options[:api_id].nil?
      raise ArgumentError, ':api_token does not exist in options hash' if options[:api_token].nil?
      raise ArgumentError, ':api_name does not exist in options hash' if options[:api_name].nil?
      raise ArgumentError, ':api_site does not exist in options hash or is invalid, this should be set to either :scout or :guide' unless [:scout, :guide].include?(options[:api_site])
      raise ArgumentError, ':default_cache_ttl must be greater than 0' unless (options[:default_cache_ttl].nil? || options[:default_cache_ttl].to_i > 0)

      @@api_id = options[:api_id]
      @@api_token = options[:api_token]
      @@api_name = options[:api_name]
      @@api_site = options[:api_site]
      @@default_cache_ttl = options[:default_cache_ttl].to_i unless options[:default_cache_ttl].nil?
    end

    # Get the API ID used in this class
    # @returns the API ID
    def self.api_id
      return @@api_id
    end

    # Get the API name displayed in the External Access tab of OSM
    # @returns the API ID
    def self.api_name
      return @@api_name
    end

    # Get the userid and secret to be able to act as a certain user on the OSM system
    # @param email the login email address of the user on OSM
    # @param password the login password of the user on OSM
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, nil if the data was retrieved from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) is a hash containing the following keys:
    #     * 'userid' - the userid to use in future requests
    #     * 'secret' - the secret to use in future requests
    #   * :data - (only if :http_error is false and :osm_error is true) a string containing the error message from OSM
    def authorize(email, password)
      api_data = {
        'email' => email,
        'password' => password,
      }
      perform_query('users.php?action=authorise', api_data)
    end

    # Get the user's roles
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and osm_error is true) this is an empty array
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::Role objects
    def get_roles(api_data={})
      if Rails.cache.exist?("OSMAPI-roles-#{api_data[:userid] || @userid}")
        return {
          :data => Rails.cache.read("OSMAPI-roles-#{api_data[:userid] || @userid}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query('api.php?action=getUserRoles', api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data].each do |item|
          role = OSM::Role.new(item)
          result.push role
          Rails.cache.write("OSMAPI-section-#{role.section.id}", role.section, :expires_in => @@default_cache_ttl*2)
          self.user_can_access :section, role.section.id, api_data
        end
      end
      Rails.cache.write("OSMAPI-roles-#{api_data[:userid] || @userid}", result, :expires_in => @@default_cache_ttl*2)
      response[:data] = result

      return response
    end

    # Get the sections (and their configuration) that the OSM user can access
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::Section objects
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_sections(api_data={})
      if Rails.cache.exist?("OSMAPI-sections-#{api_data[:userid] || @userid}")
        return {
          :data => Rails.cache.read("OSMAPI-sections-#{api_data[:userid] || @userid}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query('api.php?action=getSectionConfig', api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data].each_key do |key|
          section = OSM::Section.new(key, response[:data][key])
          result.push section
          Rails.cache.write("OSMAPI-section-#{key}", section, :expires_in => @@default_cache_ttl*2)
          self.user_can_access :section, key, api_data
        end
      end
      Rails.cache.write("OSMAPI-sections-#{api_data[:userid] || @userid}", result, :expires_in => @@default_cache_ttl*2)
      response[:data] = result

      return response
    end

    # Get the section (and its configuration)
    # @param section_id the section id of the required section
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns nil if an error occured or the user does not have access to that section
    # @returns an OSM::SectionConfig object otherwise
    def get_section(section_id, api_data={})
      if Rails.cache.exist?("OSMAPI-section-#{section_id}") && self.user_can_access?(:section, section_id, api_data)
        return Rails.cache.read("OSMAPI-section-#{section_id}")
      end

      sections = get_sections(api_data)[:data]
      return nil unless sections.class == Array

      sections.each do |section|
        return section if section.id == section_id
      end

      return nil
    end

    # Get the groupings (e.g. patrols, sixes, lodges) for a given section
    # @param section_id the section to get the programme for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::Patrol objects
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_groupings(section_id, api_data={})
      if Rails.cache.exist?("OSMAPI-groupings-#{section_id}") && self.user_can_access?(:section, section_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-groupings-#{section_id}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query("users.php?action=getPatrols&sectionid=#{section_id}", api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data]['patrols'].each do |item|
          grouping = OSM::Grouping.new(item)
          result.push grouping
          Rails.cache.write("OSMAPI-grouping-#{grouping.id}", grouping, :expires_in => @@default_cache_ttl*2)
          self.user_can_access :grouping, grouping.id, api_data
        end
        Rails.cache.write("OSMAPI-groupings-#{section_id}", result, :expires_in => @@default_cache_ttl*2)
      end
      response[:data] = result

      return response
    end

    # Get the terms that the OSM user can access
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::Term objects
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_terms(api_data={})
      if Rails.cache.exist?("OSMAPI-terms-#{api_data[:userid] || @userid}")
        return {
          :data => Rails.cache.read("OSMAPI-terms-#{api_data[:userid] || @userid}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query('api.php?action=getTerms', api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data].each_key do |key|
          response[:data][key].each do |item|
            term = OSM::Term.new(item)
            result.push term
            Rails.cache.write("OSMAPI-term-#{term.id}", term, :expires_in => @@default_cache_ttl*2)
            self.user_can_access :term, term.id, api_data
          end
        end
        Rails.cache.write("OSMAPI-terms-#{api_data[:userid] || @userid}", result, :expires_in => @@default_cache_ttl*2)
      end
      response[:data] = result

      return response
    end

    # Get the programme for a given term
    # @param sectionid the section to get the programme for
    # @param termid the term to get the programme for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::ProgrammeItem objects
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_programme(section_id, term_id, api_data={})
      if Rails.cache.exist?("OSMAPI-programme-#{section_id}") && self.user_can_access?(:programme, section_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-programme-#{section_id}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query("programme.php?action=getProgramme&sectionid=#{section_id}&termid=#{term_id}", api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data] = {'items'=>[],'activities'=>{}} if response[:data].class == Array
        self.user_can_access(:programme, section_id, api_data) unless response[:data].class == Array
        items = response[:data]['items'] || []
        activities = response[:data]['activities'] || []

        items.each do |item|
          programme_item = OSM::ProgrammeItem.new(item, activities[item['eveningid']])
          result.push programme_item
          programme_item.activities.each do |activity|
            self.user_can_access :activity, activity.activity_id, api_data
          end
        end
      end
      response[:data] = result

      Rails.cache.write("OSMAPI-programme-#{section_id}", result, :expires_in => @@default_cache_ttl)
      return response
    end

    # Get activity details
    # @param activity_id the activity ID
    # @param version (optional) the version of the activity to retreive
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an OSM::Activity object
    #   * :data - (only if :http_error is false and osm_error is true) nil
    def get_activity(activity_id, version=nil, api_data={})
      if Rails.cache.exist?("OSMAPI-activity-#{activity_id}-#{version}") && self.user_can_access?(:activity, activity_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-activity-#{activity_id}-#{version}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = nil
      if version.nil?
        response = perform_query("programme.php?action=getActivity&id=#{activity_id}", api_data)
      else
        response = perform_query("programme.php?action=getActivity&id=#{activity_id}&version=#{version}", api_data)
      end

      # If sucessful make result an Activity object
      unless response[:http_error] || response[:osm_error]
        activity = OSM::Activity.new(response[:data])
        Rails.cache.write("OSMAPI-activity-#{activity_id}-#{nil}", activity, :expires_in => @@default_cache_ttl*2) if version.nil?
        Rails.cache.write("OSMAPI-activity-#{activity_id}-#{activity.version}", activity, :expires_in => @@default_cache_ttl/2)
        self.user_can_access :activity, activity.id, api_data
        response[:data] = activity
      else
        response[:data] = nil
      end

      return response
    end

    # Get member details
    # @section_id the section to get details for
    # @term_id (optional) the term to get details for, if it is omitted then the current term is used
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::Member objects
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_members(section_id, term_id=nil, api_data={})
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if Rails.cache.exist?("OSMAPI-members-#{section_id}-#{term_id}") && self.user_can_access?(:member, section_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-members-#{section_id}-#{term_id}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query("users.php?action=getUserDetails&sectionid=#{section_id}&termid=#{term_id}", api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data]['items'].each do |item|
          result.push OSM::Member.new(item)
        end
        self.user_can_access :member, section_id, api_data
        Rails.cache.write("OSMAPI-members-#{section_id}-#{term_id}", result, :expires_in => @@default_cache_ttl)
      end
      response[:data] = result

      return response
    end

    # Get API access details for a given section
    # @section_id the section to get details for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::ApiAccess objects
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_api_access(section_id, api_data={})
      response = perform_query("users.php?action=getAPIAccess&sectionid=#{section_id}", api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data]['apis'].each do |item|
          this_item = OSM::ApiAccess.new(item)
          result.push this_item
          self.user_can_access(:programme, section_id, api_data) if this_item.can_read?(:programme)
          self.user_can_access(:member, section_id, api_data) if this_item.can_read?(:member)
          self.user_can_access(:badge, section_id, api_data) if this_item.can_read?(:badge)
        end
      end
      response[:data] = result

      return response
    end

    # Get our API access details for a given section
    # @section_id the section to get details for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an OSM::ApiAccess objects
    #   * :data - (only if :http_error is false and osm_error is true) nil
    def get_our_api_access(section_id, api_data={})
      response = get_api_access(section_id, api_data)
      found = nil
      response[:data].each do |item|
        found = item if item.our_api?
      end
      response[:data] = found

      return response
    end

    # Get events
    # @section_id the section to get details for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of OSM::Event objects
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_events(section_id, api_data={})
      if Rails.cache.exist?("OSMAPI-events-#{section_id}") && self.user_can_access?(:programme, section_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-events-#{section_id}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query("events.php?action=getEvents&sectionid=#{section_id}", api_data)

      result = Array.new
      unless response[:http_error] || response[:osm_error]
        response[:data]['items'].each do |item|
          result.push OSM::Event.new(item)
        end
        self.user_can_access :programme, section_id, api_data
        Rails.cache.write("OSMAPI-events-#{section_id}", result, :expires_in => @@default_cache_ttl)
      end
      response[:data] = result

      return response
    end

    # Get due badges
    # @section_id the section to get details for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) a OSM::DueBadges objects
    #   * :data - (only if :http_error is false and osm_error is true) nil
    def get_due_badges(section_id, term_id=nil, api_data={})
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if Rails.cache.exist?("OSMAPI-due_badges-#{section_id}") && self.user_can_access?(:badge, section_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-due_badges-#{section_id}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query("challenges.php?action=outstandingBadges&sectionid=#{section_id}&termid=#{term_id}", api_data)

      # If sucessful make result a OSM::DueBadges object
      unless response[:http_error] || response[:osm_error]
        response[:data] = OSM::DueBadges.new(response[:data])
        self.user_can_access :badge, section_id, api_data
        Rails.cache.write("OSMAPI-due_badges-#{section_id}", response[:data], :expires_in => @@default_cache_ttl*2)
      else
        response[:data] = nil
      end

      return response
    end

    # Get register structure
    # @section_id the section to get details for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of hashes representing the rows of the register
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_register_structure(section_id, term_id=nil, api_data={})
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if Rails.cache.exist?("OSMAPI-register_structure-#{section_id}-#{term_id}") && self.user_can_access?(:register, section_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-register_structure-#{section_id}-#{term_id}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query("users.php?action=registerStructure&sectionid=#{section_id}&termid=#{term_id}", api_data)

      unless response[:http_error] || response[:osm_error]
        data = response[:data]
        data.each do |item|
          item.symbolize_keys!
          item[:rows].each do |row|
            row.symbolize_keys!
          end
        end
        self.user_can_access :register, section_id, api_data
        Rails.cache.write("OSMAPI-register_structure-#{section_id}-#{term_id}", api_data, :expires_in => @@default_cache_ttl/2)
        response[:data] = data
      else
        response[:data] = []
      end

      return response
    end

    # Get register
    # @section_id the section to get details for
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash containing the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request, only if the data was not fetched from the cache
    #   * :data - (only if :http_error is false and :osm_error is false) an array of hashes representing the attendance of a member
    #   * :data - (only if :http_error is false and osm_error is true) an empty array
    def get_register(section_id, term_id=nil, api_data={})
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if Rails.cache.exist?("OSMAPI-register-#{section_id}-#{term_id}") && self.user_can_access?(:register, section_id, api_data)
        return {
          :data => Rails.cache.read("OSMAPI-register-#{section_id}-#{term_id}"),
          :http_error => false,
          :osm_error => false
        }
      end

      response = perform_query("users.php?action=register&sectionid=#{section_id}&termid=#{term_id}", api_data)

      unless response[:http_error] || response[:osm_error]
        data = response[:data]['items']
        data.each do |item|
          item.symbolize_keys!
          item[:scoutid] = item[:scoutid].to_i
          item[:sectionid] = item[:sectionid].to_i
          item[:patrolid] = item[:patrolid].to_i
        end
        self.user_can_access :register, section_id, api_data
        Rails.cache.write("OSMAPI-register-#{section_id}-#{term_id}", data, :expires_in => @@default_cache_ttl/2)
        response[:data] = data
      else
        response[:data] = []
      end

      return response
    end

    private
    # Make the query to the OSM API
    # @param url the script on the remote server to invoke
    # @param api_data (optional) a hash containing the values to be sent to the server
    # @returns a hash with the following keys:
    #   * :http_error - false if no error occured, otherwise an integer of the HTTP status code
    #   * :osm_error - false if no error occured, otherwise a string containing the error message
    #   * :response - what HTTParty returned when making the request
    #   * :data - (only if :http_error is false and osm_error is false) the parsed JSON returned by OSM
    def perform_query(url, api_data={})
      api_data['apiid'] = @@api_id
      api_data['token'] = @@api_token

      if (api_data['userid'].nil? || api_data['secret'].nil?)
        unless (@userid.nil? || @secret.nil?)
          api_data['userid'] = @userid
          api_data['secret'] = @secret
        end
      end

      result = HTTParty.post("#{@base_url}/#{url}", {:body => api_data})
      to_return = {
        :http_error => !result.response.code.eql?('200') ? result.response.code : false,
        :osm_error => result.response.body[0..8].eql?('{"error":'),
        :response => result,
      }

      unless to_return[:http_error]
        unless to_return[:osm_error]
          to_return[:data] = ActiveSupport::JSON.decode(result.response.body)
        else
          to_return[:osm_error] = ActiveSupport::JSON.decode(result.response.body)['error']
        end
      end
      return to_return
    end

    protected
    # Set access permission for the current user on a resource stored in the cache
    # @param resource_type a symbol representing the resource type (:section, :grouping, :term, :activity, :programme, :member, :badge, :register)
    # @param resource_id the id of the resource being checked
    # @param api_data the data hash used in accessing the api
    # @param permission (optional, default true) wether the user can access the resource
    def user_can_access(resource_type, resource_id, api_data, permission=true)
      user = (api_data['userid'] || @userid).to_i
      resource_id = resource_id.to_i
      resource_type = resource_type.to_sym

      @@user_access[user] = {} if @@user_access[user].nil?
      @@user_access[user][resource_type] = {} if @@user_access[user][resource_type].nil?

      @@user_access[user][resource_type][resource_id] = permission
    end

    # Get access permission for the current user on a resource stored in the cache
    # @param resource_type a symbol representing the resource type (:section, :grouping, :term, :activity, :programme, :member, :badge, :register)
    # @param resource_id the id of the resource being checked
    # @param api_data the data hash used in accessing the api
    # @returns true if the user can access the resource
    # @returns false if the user can not access the resource
    # @returns nil if the combination of user and resource has not been seen
    def user_can_access?(resource_type, resource_id, api_data)
      user = (api_data['userid'] || @userid).to_i
      resource_id = resource_id.to_i
      resource_type = resource_type.to_sym

      return nil if @@user_access[user].nil?
      return nil if @@user_access[user][resource_type].nil?
      return @@user_access[user][resource_type][resource_id]
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

    attr_reader :id, :subscription_level, :subscription_expires, :type, :num_scouts, :has_badge_records, :has_programme, :wizard, :column_names, :fields, :intouch_fields, :mobile_fields, :extra_records

    # Initialize a new SectionConfig using the hash returned by the API call
    # @param id the section ID used by the API to refer to this section
    # @param data the hash of data for the object returned by the API
    def initialize(id, data)
      subscription_levels = [:bronze, :silver, :gold]

      @id = id.to_i
      @subscription_level = subscription_levels[data['subscription_level'] - 1]
      @subscription_expires = Date.parse(data['subscription_expires'], 'yyyy-mm-dd')
      @type = data['sectionType'].to_sym
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


  class Term

    attr_reader :id, :section_id, :name, :start, :end

    # Initialize a new Term using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['termid'].to_i
      @section_id = data['sectionid'].to_i
      @name = data['name']
      @start = Date.parse(data['startdate'], 'yyyy-mm-dd')
      @end = Date.parse(data['enddate'], 'yyyy-mm-dd')
    end

    # Determine if the term is completly before the passed date
    # @param date
    # @returns true if the term is completly before the passed date
    def before?(date)
      return @end < date.to_date
    end

    # Determine if the term is completly after the passed date
    # @param date
    # @returns true if the term is completly after the passed date
    def after?(date)
      return @start > date.to_date
    end

    # Determine if the term is in the future
    # @returns true if the term starts after today
    def future?
      return @start > Date.today
    end

    # Determine if the term is in the past
    # @returns true if the term finished before today
    def past?
      return @end < Date.today
    end

    # Determine if the term is current
    # @returns true if the term started before today and finishes after today
    def current?
      return (@start < Date.today) && (@end > Date.today)
    end

    # Determine if the provided date is within the term
    # @param date the date to test
    # @returns true if the term started before the date and finishes after the date
    def contains_date?(date)
      return (@start < date) && (@end > date)
    end

  end


  class ProgrammeItem

    attr_reader :evening_id, :section_id, :title, :notes_for_parents, :games, :pre_notes, :post_notes, :leaders, :meeting_date, :start, :end, :activities

    # Initialize a new ProgrammeItem using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    # @param activities an array of hashes to generate the list of ProgrammeActivity objects
    def initialize(data, activities)
      @evening_id = data['eveningid']
      @section_id = data['sectionid']
      @title = data['title']
      @notes_for_parents = data['notes_for_parents']
      @games = data['games']
      @pre_notes = data['prenotes']
      @post_notes = data['postnotes']
      @leaders = data['leaders']
      @start = DateTime.parse((data['meetingdate'] + ' ' + data['starttime']), 'yyyy-mm-dd hh:mm:ss')
      @end = DateTime.parse((data['meetingdate'] + ' ' + data['endtime']), 'yyyy-mm-dd hh:mm:ss')

      @activities = Array.new
      unless activities.nil?
        activities.each do |item|
          @activities.push OSM::ProgrammeActivity.new(item)
        end
      end
    end

  end


  class ProgrammeActivity

    attr_reader :evening_id, :activity_id, :title, :notes

    # Initialize a new EveningActivity using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @evening_id = data['eveningid']
      @activity_id = data['activityid']
      @title = data['title']
      @notes = data['notes']
    end

  end


  class Activity

    attr_reader :id, :version, :group_id, :user_id, :title, :description, :resources, :instructions, :running_time, :location, :shared, :rating, :editable, :deletable, :used, :versions, :sections, :tags, :files, :badges

    # Initialize a new Activity using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['details']['activityid']
      @version = data['details']['version']
      @group_id = data['details']['groupid']
      @user_id = data['details']['userid']
      @title = data['details']['title']
      @description = data['details']['description']
      @resources = data['details']['resources']
      @instructions = data['details']['instructions']
      @running_time = data['details']['runningtime'].to_i
      @location = data['details']['location']
      @shared = data['details']['shared']
      @rating = data['details']['rating']
      @editable = data['editable']
      @deletable = data['deletable']
      @used = data['used']
      @versions = data['versions']
      @sections = OSM::make_array_of_symbols(data['sections'])
      @tags = data['tags'] || []
      @files = data['files']
      @badges = data['badges']
    end

  end


  class Member

    attr_reader :id, :section_id, :type, :first_name, :last_name, :email1, :email2, :email3, :email4, :phone1, :phone2, :phone3, :phone4, :address, :address2, :date_of_birth, :started, :joined_in_years, :parents, :notes, :medical, :religion, :school, :enthnicity, :subs, :grouping_id, :grouping_leader, :joined, :age, :joined_years, :patrol

    # Initialize a new Member using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['scoutid']
      @section_id = data['sectionid']
      @type = data['type']
      @first_name = data['firstname']
      @last_name = data['lastname']
      @email1 = data['email1']
      @email2 = data['email2']
      @email3 = data['email3']
      @email4 = data['email4']
      @phone1 = data['phone1']
      @phone2 = data['phone2']
      @phone3 = data['phone3']
      @phone4 = data['phone4']
      @address = data['address']
      @address2 = data['address2']
      @date_of_birth = Date.parse(data['dob'], 'yyyy-mm-dd')
      @started = data['started']
      @joined_in_years = data['joining_in_yrs']
      @parents = data['parents']
      @notes = data['notes']
      @medical = data['medical']
      @religion = data['religion']
      @school = data['school']
      @ethnicity = data['ethnicity']
      @subs = data['subs']
      @grouping_id = data['patrolid'].to_i
      @grouping_leader = data['patrolleader'] # 0 - No, 1 = seconder, 2 = sixer
      @joined = Date.parse(data['joined'], 'yyyy-mm-dd')
      @age = data['age'] # 'yy / mm'
      @joined_years = data['yrs']
      @patrol = data['patrol']
    end

    # Get the years element of this scout's age
    # @returns the number of years this scout has been alive
    def age_years
      return @age[0..1].to_i
    end

    # Get the months element of this scout's age
    # @returns the number of months since this scout's last birthday
    def age_months
      return @age[-2..-1].to_i
    end

    # Get the full name
    # @param seperator (optional) what to split the scout's first name and last name with, defaults to a space
    # @returns this scout's full name seperate by the optional seperator
    def name(seperator=' ')
      return "#{@first_name}#{seperator.to_s}#{@last_name}"
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


  class Grouping

    attr_reader :id, :name, :active

    # Initialize a new Grouping using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['patrolid']
      @name = data['name']
      @active = data['active'] == 1
    end

  end


  class Event

    attr_reader :id, :section_id, :name, :start, :end, :cost, :location, :notes

    # Initialize a new Event using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['eventid']
      @section_id = data['sectionid']
      @name = data['name']
      @start = data['startdate'] ? DateTime.parse((data['startdate'] + ' ' + data['starttime']), 'yyyy-mm-dd hh:mm:ss') : nil
      @end = data['enddate'] ? DateTime.parse((data['enddate'] + ' ' + data['endtime']), 'yyyy-mm-dd hh:mm:ss') : nil
      @cost = data['cost']
      @location = data['location']
      @notes = data['notes']
    end

  end


  class DueBadges

    attr_reader :descriptions, :by_member, :totals

    # Initialize a new Event using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @pending = data['pending'].symbolize_keys
      @descriptions = data['description'].symbolize_keys

      @pending.each_key do |key|
        @pending[key].each do |item|
          item.symbolize_keys!
          item[:sid] = item[:sid].to_i
          item[:completed] = item[:completed].to_i
        end
      end
      @descriptions.each_key do |key|
        @descriptions[key].symbolize_keys!
        @descriptions[key][:section] = @descriptions[key][:section].to_sym
        @descriptions[key][:type] = @descriptions[key][:type].to_sym
      end


      @by_member = {}
      @totals = {}
      @pending.each_key do |key|
        @pending[key].each do |item|
          name = "#{item[:firstname]} #{item[:lastname]}"
          by_member[name] = [] if by_member[name].nil?

          badge = {
            :badge => key,
            :extra_information => item[:extra]
          }
          by_member[name].push badge
          @totals[key] = {} if @totals[key].nil?
          @totals[key][item[:extra]] = @totals[key][item[:extra]].to_i + 1
        end
      end
    end

  end


  private
  def self.make_array_of_symbols(array)
    array.each_with_index do |item, index|
      array[index] = item.to_sym
    end
  end

  def self.find_current_term_id(api, section_id, data={})
    terms = api.get_terms(data)[:data]
    unless terms.nil?
      terms.each do |term|
        return term.id if term.current? && (term.section_id == section_id)
      end
    end
    return nil
  end


end
