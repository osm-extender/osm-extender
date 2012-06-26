module OSM

  class Error < Exception; end
  class ConnectionError < Error; end

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
      @base_url = 'http://www.onlineguidemanager.co.uk' if site == :guide
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
    # @returns hash containing the following keys:
    #   * 'userid' - the userid to use in future requests
    #   * 'secret' - the secret to use in future requests
    def authorize(email, password)
      api_data = {
        'email' => email,
        'password' => password,
      }
      perform_query('users.php?action=authorise', api_data)
    end

    # Get the user's roles
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of OSM::Role objects
    def get_roles(options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-roles-#{api_data[:userid] || @userid}")
        return Rails.cache.read("OSMAPI-roles-#{api_data[:userid] || @userid}")
      end

      data = perform_query('api.php?action=getUserRoles', api_data)

      result = Array.new
      data.each do |item|
        role = OSM::Role.new(item)
        result.push role
        Rails.cache.write("OSMAPI-section-#{role.section.id}", role.section, :expires_in => @@default_cache_ttl*2)
        self.user_can_access :section, role.section.id, api_data
      end
      Rails.cache.write("OSMAPI-roles-#{api_data[:userid] || @userid}", result, :expires_in => @@default_cache_ttl*2)

      return result
    end

    # Get the user's notepads
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a hash (keys are section IDs, values are a string)
    def get_notepads(options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-notepads-#{api_data[:userid] || @userid}")
        return Rails.cache.read("OSMAPI-notepads-#{api_data[:userid] || @userid}")
      end

      data = perform_query('api.php?action=getNotepads', api_data)
      data = {} unless data.is_a?(Hash)

      data.each_key do |key|
        Rails.cache.write("OSMAPI-notepad-#{key}", data[key], :expires_in => @@default_cache_ttl*2)
      end

      Rails.cache.write("OSMAPI-notepads-#{api_data[:userid] || @userid}", data, :expires_in => @@default_cache_ttl*2)
      return data
    end

    # Get the notepad for a specified section
    # @param section_id the section id of the required section
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns nil if an error occured or the user does not have access to that section
    # @returns a string otherwise
    def get_notepad(section_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-notepad-#{section_id}") && self.user_can_access?(:section, section_id, api_data)
        return Rails.cache.read("OSMAPI-notepad-#{section_id}")
      end

      notepads = get_notepads(options)
      return nil unless notepads.is_a? Hash

      notepads.each_key do |key|
        return notepads[key] if key.to_i == section_id
      end

      return nil
    end

    # Get the section (and its configuration)
    # @param section_id the section id of the required section
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns nil if an error occured or the user does not have access to that section
    # @returns an OSM::SectionConfig object otherwise
    def get_section(section_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-section-#{section_id}") && self.user_can_access?(:section, section_id, api_data)
        return Rails.cache.read("OSMAPI-section-#{section_id}")
      end

      roles = get_roles(options)
      return nil unless roles.is_a? Array

      roles.each do |role|
        return role.section if role.section.id == section_id
      end

      return nil
    end

    # Get the groupings (e.g. patrols, sixes, lodges) for a given section
    # @param section_id the section to get the programme for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of OSM::Patrol objects
    def get_groupings(section_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-groupings-#{section_id}") && self.user_can_access?(:section, section_id, api_data)
        return Rails.cache.read("OSMAPI-groupings-#{section_id}")
      end

      data = perform_query("users.php?action=getPatrols&sectionid=#{section_id}", api_data)

      result = Array.new
      data['patrols'].each do |item|
        grouping = OSM::Grouping.new(item)
        result.push grouping
        Rails.cache.write("OSMAPI-grouping-#{grouping.id}", grouping, :expires_in => @@default_cache_ttl*2)
        self.user_can_access :grouping, grouping.id, api_data
      end
      Rails.cache.write("OSMAPI-groupings-#{section_id}", result, :expires_in => @@default_cache_ttl*2)

      return result
    end

    # Get the terms that the OSM user can access
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns  an array of OSM::Term objects
    def get_terms(options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-terms-#{api_data[:userid] || @userid}")
        return Rails.cache.read("OSMAPI-terms-#{api_data[:userid] || @userid}")
      end

      data = perform_query('api.php?action=getTerms', api_data)

      result = Array.new
      data.each_key do |key|
        data[key].each do |item|
          term = OSM::Term.new(item)
          result.push term
          Rails.cache.write("OSMAPI-term-#{term.id}", term, :expires_in => @@default_cache_ttl*2)
          self.user_can_access :term, term.id, api_data
        end
      end

      Rails.cache.write("OSMAPI-terms-#{api_data[:userid] || @userid}", result, :expires_in => @@default_cache_ttl*2)
      return result
    end

    # Get a term
    # @param term_id the id of the required term
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns nil if an error occured or the user does not have access to that term
    # @returns an OSM::Term object otherwise
    def get_term(term_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-term-#{term_id}") && self.user_can_access?(:term, term_id, api_data)
        return Rails.cache.read("OSMAPI-term-#{term_id}")
      end

      terms = get_terms(options)
      return nil unless terms.is_a? Array

      terms.each do |term|
        return term if term.id == term_id
      end

      return nil
    end

    # Get the programme for a given term
    # @param sectionid the section to get the programme for
    # @param termid the term to get the programme for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of OSM::ProgrammeItem objects
    def get_programme(section_id, term_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-programme-#{section_id}-#{term_id}") && self.user_can_access?(:programme, section_id, api_data)
        return Rails.cache.read("OSMAPI-programme-#{section_id}-#{term_id}")
      end

      data = perform_query("programme.php?action=getProgramme&sectionid=#{section_id}&termid=#{term_id}", api_data)

      result = Array.new
      data = {'items'=>[],'activities'=>{}} if data.is_a? Array
      self.user_can_access(:programme, section_id, api_data) unless data.is_a? Array
      items = data['items'] || []
      activities = data['activities'] || {}

      items.each do |item|
        programme_item = OSM::ProgrammeItem.new(item, activities[item['eveningid']])
        result.push programme_item
        programme_item.activities.each do |activity|
          self.user_can_access :activity, activity.activity_id, api_data
        end
      end

      Rails.cache.write("OSMAPI-programme-#{section_id}-#{term_id}", result, :expires_in => @@default_cache_ttl)
      return result
    end

    # Get activity details
    # @param activity_id the activity ID
    # @param version (optional) the version of the activity to retreive
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an OSM::Activity object
    def get_activity(activity_id, version=nil, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-activity-#{activity_id}-#{version}") && self.user_can_access?(:activity, activity_id, api_data)
        return Rails.cache.read("OSMAPI-activity-#{activity_id}-#{version}")
      end

      data = nil
      if version.nil?
        data = perform_query("programme.php?action=getActivity&id=#{activity_id}", api_data)
      else
        data = perform_query("programme.php?action=getActivity&id=#{activity_id}&version=#{version}", api_data)
      end

      activity = OSM::Activity.new(data)
      Rails.cache.write("OSMAPI-activity-#{activity_id}-#{nil}", activity, :expires_in => @@default_cache_ttl*2) if version.nil?
      Rails.cache.write("OSMAPI-activity-#{activity_id}-#{activity.version}", activity, :expires_in => @@default_cache_ttl/2)
      self.user_can_access :activity, activity.id, api_data

      return activity
    end

    # Get member details
    # @section_id the section to get details for
    # @term_id (optional) the term to get details for, if it is omitted then the current term is used
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of OSM::Member objects
    def get_members(section_id, term_id=nil, options={})
      api_data = options[:api_data] || {}
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-members-#{section_id}-#{term_id}") && self.user_can_access?(:member, section_id, api_data)
        return Rails.cache.read("OSMAPI-members-#{section_id}-#{term_id}")
      end

      data = perform_query("users.php?action=getUserDetails&sectionid=#{section_id}&termid=#{term_id}", api_data)

      result = Array.new
      data['items'].each do |item|
        result.push OSM::Member.new(item)
      end
      self.user_can_access :member, section_id, api_data
      Rails.cache.write("OSMAPI-members-#{section_id}-#{term_id}", result, :expires_in => @@default_cache_ttl)

      return result
    end

    # Get API access details for a given section
    # @param section_id the section to get details for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of OSM::ApiAccess objects
    def get_api_access(section_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-api_access-#{api_data['userid'] || @userid}-#{section_id}")
        return Rails.cache.read("OSMAPI-api_access-#{api_data['userid'] || @userid}-#{section_id}")
      end

      data = perform_query("users.php?action=getAPIAccess&sectionid=#{section_id}", api_data)

      result = Array.new
      data['apis'].each do |item|
        this_item = OSM::ApiAccess.new(item)
        result.push this_item
        self.user_can_access(:programme, section_id, api_data) if this_item.can_read?(:programme)
        self.user_can_access(:member, section_id, api_data) if this_item.can_read?(:member)
        self.user_can_access(:badge, section_id, api_data) if this_item.can_read?(:badge)
        Rails.cache.write("OSMAPI-api_access-#{api_data['userid'] || @userid}-#{section_id}-#{this_item.id}", this_item, :expires_in => @@default_cache_ttl*2)
      end

      return result
    end

    # Get our API access details for a given section
    # @param section_id the section to get details for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an OSM::ApiAccess objects
    def get_our_api_access(section_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-api_access-#{api_data['userid'] || @userid}-#{section_id}-#{OSM::API.api_id}")
        return Rails.cache.read("OSMAPI-api_access-#{api_data['userid'] || @userid}-#{section_id}-#{OSM::API.api_id}")
      end

      data = get_api_access(section_id, options)
      found = nil
      data.each do |item|
        found = item if item.our_api?
      end

      return found
    end

    # Get events
    # @section_id the section to get details for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of OSM::Event objects
    def get_events(section_id, options={})
      api_data = options[:api_data] || {}

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-events-#{section_id}") && self.user_can_access?(:programme, section_id, api_data)
        return Rails.cache.read("OSMAPI-events-#{section_id}")
      end

      data = perform_query("events.php?action=getEvents&sectionid=#{section_id}", api_data)

      result = Array.new
      data['items'].each do |item|
        result.push OSM::Event.new(item)
      end
      self.user_can_access :programme, section_id, api_data
      Rails.cache.write("OSMAPI-events-#{section_id}", result, :expires_in => @@default_cache_ttl)

      return result
    end

    # Get due badges
    # @section_id the section to get details for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an OSM::DueBadges object
    def get_due_badges(section_id, term_id=nil, options={})
      api_data = options[:api_data] || {}
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-due_badges-#{section_id}-#{term_id}") && self.user_can_access?(:badge, section_id, api_data)
        return Rails.cache.read("OSMAPI-due_badges-#{section_id}-#{term_id}")
      end

      section_type = get_section(section_id, api_data).type.to_s
      data = perform_query("challenges.php?action=outstandingBadges&section=#{section_type}&sectionid=#{section_id}&termid=#{term_id}", api_data)

      data = OSM::DueBadges.new(data)
      self.user_can_access :badge, section_id, api_data
      Rails.cache.write("OSMAPI-due_badges-#{section_id}-#{term_id}", data, :expires_in => @@default_cache_ttl*2)

      return data
    end

    # Get register structure
    # @section_id the section to get details for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of hashes representing the rows of the register
    def get_register_structure(section_id, term_id=nil, options={})
      api_data = options[:api_data] || {}
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-register_structure-#{section_id}-#{term_id}") && self.user_can_access?(:register, section_id, api_data)
        return Rails.cache.read("OSMAPI-register_structure-#{section_id}-#{term_id}")
      end

      data = perform_query("users.php?action=registerStructure&sectionid=#{section_id}&termid=#{term_id}", api_data)

      data.each do |item|
        item.symbolize_keys!
        item[:rows].each do |row|
          row.symbolize_keys!
        end
      end
      self.user_can_access :register, section_id, api_data
      Rails.cache.write("OSMAPI-register_structure-#{section_id}-#{term_id}", data, :expires_in => @@default_cache_ttl/2)

      return data
    end

    # Get register
    # @section_id the section to get details for
    # @param options (optional) a hash which may contain the following keys:
    #   * :no_cache - if true then the data will be retreived from OSM not the cache
    #   * :api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #     * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #     * 'secret' (optional) the OSM secret belonging to the above user
    # @returns an array of hashes representing the attendance of each member
    def get_register(section_id, term_id=nil, options={})
      api_data = options[:api_data] || {}
      term_id = OSM.find_current_term_id(self, section_id, api_data) if term_id.nil?

      if !options[:no_cache] && Rails.cache.exist?("OSMAPI-register-#{section_id}-#{term_id}") && self.user_can_access?(:register, section_id, api_data)
        return Rails.cache.read("OSMAPI-register-#{section_id}-#{term_id}")
      end

      data = perform_query("users.php?action=register&sectionid=#{section_id}&termid=#{term_id}", api_data)

      data = data['items']
      data.each do |item|
        item.symbolize_keys!
        item[:scoutid] = item[:scoutid].to_i
        item[:sectionid] = item[:sectionid].to_i
        item[:patrolid] = item[:patrolid].to_i
      end
      self.user_can_access :register, section_id, api_data
      Rails.cache.write("OSMAPI-register-#{section_id}-#{term_id}", data, :expires_in => @@default_cache_ttl/2)
      return data
    end

    # Create an evening in OSM
    # @param section_id the id of the section to add the term to
    # @param meeting_date the date of the meeting
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a boolean representing if the operation suceeded or not
    def create_evening(section_id, meeting_date, api_data={})
      section_id = section_id.to_i
      evening_api_data = {
        'meetingdate' => meeting_date.strftime('%Y-%m-%d'),
        'sectionid' => section_id,
        'activityid' => -1
      }

      data = perform_query("programme.php?action=addActivityToProgramme", api_data.merge(evening_api_data))

      # The cached programmes for the section will be out of date - remove them
      get_terms(api_data).each do |term|
        Rails.cache.delete("OSMAPI-programme-#{term.section_id}-#{term.id}") if term.section_id == section_id
      end

      return data
    end

    # Update an evening in OSM
    # @param programme_item is the OSM::ProgrammeItem object to update
    # @param api_data (optional) a hash containing information to be sent to the server, it may contain the following keys:
    #   * 'userid' (optional) the OSM userid to make the request as, this will override one provided using the set_user method
    #   * 'secret' (optional) the OSM secret belonging to the above user
    # @returns a boolean representing if the operation suceeded or not
    def update_evening(programme_item, api_data={})
      response = perform_query("programme.php?action=editEvening", api_data.merge({
        'eveningid' => programme_item.evening_id,
        'sectionid' => programme_item.section_id,
        'meetingdate' => programme_item.meeting_date.strftime('%Y-%m-%d'),
        'starttime' => programme_item.start_time,
        'endtime' => programme_item.end_time,
        'title' => programme_item.title,
        'notesforparents' => programme_item.notes_for_parents,
        'prenotes' => programme_item.pre_notes,
        'postnotes' => programme_item.post_notes,
        'games' => programme_item.games,
        'leaders' => programme_item.leaders,
        'activity' => programme_item.activities_for_saving,
        'googlecalendar' => programme_item.google_calendar || '',
      }))

      # The cached programmes for the section will be out of date - remove them
      get_terms(api_data).each do |term|
        Rails.cache.delete("OSMAPI-programme-#{term.section_id}-#{term.id}") if term.section_id == programme_item.section_id
      end

      return response
    end

    private
    # Make the query to the OSM API
    # @param url the script on the remote server to invoke
    # @param api_data (optional) a hash containing the values to be sent to the server
    # @returns the parsed JSON returned by OSM
    def perform_query(url, api_data={})
      api_data['apiid'] = @@api_id
      api_data['token'] = @@api_token

      if api_data['userid'].nil? && api_data['secret'].nil?
        unless @userid.nil? || @secret.nil?
          api_data['userid'] = @userid
          api_data['secret'] = @secret
        end
      end

      if Rails.env.development?
        puts "Making OSM API request to #{url}"
        puts api_data.to_s
      end

      begin
        result = HTTParty.post("#{@base_url}/#{url}", {:body => api_data})
      rescue SocketError, TimeoutError, FakeWeb::NetConnectNotAllowedError
        raise ConnectionError.new('A problem occured on the internet.')
      end
      raise ConnectionError.new("HTTP Status code was #{result.response.code}") if !result.response.code.eql?('200')

      if Rails.env.development?
        puts "Result from OSM request to #{url}"
        puts result.response.body
      end

      raise Error.new(result.response.body) unless looks_like_json?(result.response.body)
      decoded = ActiveSupport::JSON.decode(result.response.body)
      osm_error = get_osm_error(decoded)
      raise Error.new(osm_error) if osm_error
      return decoded        
    end

    def looks_like_json?(text)
      (['[', '{'].include?(text[0]))
    end

    def get_osm_error(data)
      return false unless data.is_a?(Hash)
      to_return = data['error'] || data['err'] || false
      to_return = false if to_return.blank?
      puts "OSM API ERROR: #{to_return}" if Rails.env.development? && to_return
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

    attr_reader :section, :group_name, :group_id, :group_normalized, :default, :permissions

    # Initialize a new UserRole using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @section = OSM::Section.new(data['sectionid'], data['sectionname'], ActiveSupport::JSON.decode(data['sectionConfig']), self)
      @group_name = data['groupname']
      @group_id = data['groupid'].to_i
      @group_normalized = data['groupNormalised'].to_i
      @default = data['isDefault'].eql?('1') ? true : false
      @permissions = (data['permissions'] || {}).symbolize_keys

      # Convert permission values to a number
      @permissions.each_key do |key|
        @permissions[key] = @permissions[key].to_i
      end
    end

    # Determine if this role has read access for the provided permission
    # @param key - the key for the permission being queried
    # @returns - true if this role can read the passed permission, false otherwise
    def can_read?(key)
      return [10, 20, 100].include?(@permissions[key])
    end

    # Determine if this role has write access for the provided permission
    # @param key - the key for the permission being queried
    # @returns - true if this role can write the passed permission, false otherwise
    def can_write?(key)
      return [20, 100].include?(@permissions[key])
    end

    # Get section's full name in a consistent format
    # @returns a string e.g. "Scouts (1st Somewhere)"
    def long_name
      @group_name.blank? ? @section.name : "#{@section.name} (#{@group_name})"
    end

    # Get section's full name in a consistent format
    # @returns a string e.g. "1st Somewhere Beavers"
    def full_name
      @group_name.blank? ? @section.name : "#{@group_name} #{@section.name}"
    end

    def <=>(another_role)
      compare_group_name = self.group_name <=> another_role.group_name
      return compare_group_name unless compare_group_name == 0

      return 0 if self.section.type == another_role.section.type
      [:beavers, :cubs, :scouts, :explorers, :waiting, :adult].each do |type|
        return -1 if self.section.type == type
        return 1 if another_role.section.type == type
      end
    end

    def ==(another_role)
      self.section.id == another_role.section.id
    end

  end


  class Section

    attr_reader :id, :name, :subscription_level, :subscription_expires, :type, :num_scouts, :has_badge_records, :has_programme, :wizard, :column_names, :fields, :intouch_fields, :mobile_fields, :extra_records, :role

    # Initialize a new SectionConfig using the hash returned by the API call
    # @param id the section ID used by the API to refer to this section
    # @param data the hash of data for the object returned by the API
    def initialize(id, name, data, role)
      subscription_levels = [:bronze, :silver, :gold]

      @id = id.to_i
      @name = name
      @subscription_level = subscription_levels[data['subscription_level'] - 1]
      @subscription_expires = data['subscription_expires'] ? Date.parse(data['subscription_expires'], 'yyyy-mm-dd') : nil
      @type = !data['sectionType'].nil? ? data['sectionType'].to_sym : :unknown
      @num_scouts = data['numscouts']
      @has_badge_records = data['hasUsedBadgeRecords'].eql?('1') ? true : false
      @has_programme = data['hasProgramme']
      @wizard = (data['wizard'] || '').downcase.eql?('true') ? true : false
      @column_names = (data['columnNames'] || {}).symbolize_keys
      @fields = (data['fields'] || {}).symbolize_keys
      @intouch_fields = (data['intouch'] || {}).symbolize_keys
      @mobile_fields = (data['mobFields'] || {}).symbolize_keys
      @extra_records = data['extraRecords'] || []
      @role = role

      # Symbolise the keys in each hash of the extra_records array
      @extra_records.each do |item|
        # Expect item to be: {:name=>String, :extraid=>FixNum}
        # Sometimes get item as: [String, {"name"=>String, "extraid"=>FixNum}]
        if item.is_a?(Array)
          item = item[1].symbolize_keys
        else
          item.symbolize_keys!
        end
      end
    end

    def youth_section?
      [:beavers, :cubs, :scouts, :explorers].include?(@type)
    end

    # Custom section type checkers
    [:beavers, :cubs, :scouts, :explorers, :adult, :waiting].each do |attribute|
      define_method "#{attribute}_section?" do
        @type == attribute
      end
    end

    def <=>(another_section)
      self.role <=> another_section.role
    end

    def ==(another_section)
      self.id == another_section.id
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
      return (@start <= Date.today) && (@end >= Date.today)
    end

    # Determine if the provided date is within the term
    # @param date the date to test
    # @returns true if the term started before the date and finishes after the date
    def contains_date?(date)
      return (@start <= date) && (@end >= date)
    end

    def <=>(another_term)
      self.start <=> another_term.start
    end

  end


  class ProgrammeItem

    attr_accessor :evening_id, :section_id, :title, :notes_for_parents, :games, :pre_notes, :post_notes, :leaders, :meeting_date, :activities, :google_calendar
    attr_reader :start_time, :end_time

    # Initialize a new ProgrammeItem using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    # @param activities an array of hashes to generate the list of ProgrammeActivity objects
    def initialize(data, activities)
      @evening_id = data['eveningid']
      @section_id = data['sectionid']
      @title = data['title'] || 'Unnamed meeting'
      @notes_for_parents = data['notesforparents'] || ''
      @games = data['games'] || ''
      @pre_notes = data['prenotes'] || ''
      @post_notes = data['postnotes'] || ''
      @leaders = data['leaders'] || ''
      @start_time = data['starttime'].nil? ? nil : data['starttime'][0..4]
      @end_time = data['endtime'].nil? ? nil : data['endtime'][0..4]
      @meeting_date = Date.parse(data['meetingdate'], 'yyyy-mm-dd')
      @google_calendar = data['googlecalendar']

      @activities = Array.new
      unless activities.nil?
        activities.each do |item|
          @activities.push OSM::ProgrammeActivity.new(item)
        end
      end
    end

    # Custom setters for times
    [:start, :end].each do |attribute|
      define_method "#{attribute}_time=" do |value|
        unless value.nil?
          value = value.strftime('%H:%M') unless value.is_a?(String)
          raise ArgumentError, 'invalid time' unless /\A(?:[0-1][0-9]|2[0-3]):[0-5][0-9]\Z/.match(value)
        end
        instance_variable_set("@#{attribute}_time", value)
      end
    end

    def activities_for_saving
      to_save = Array.new
      @activities.each do |activity|
        this_activity = {
          'activityid' => activity.activity_id,
          'notes' => activity.notes,
        }
        to_save.push this_activity
      end
      return to_save.to_json
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
      @sections = OSM::make_array_of_symbols(data['sections'] || [])
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
      @date_of_birth = OSM.parse_date(data['dob'])
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
      @joined = OSM.parse_date(data['joined'])
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
      @permissions = (data['permissions'] || {}).symbolize_keys

      # Convert permission values to a number
      @permissions.each_key do |key|
        @permissions[key] = @permissions[key].to_i
      end
    end

    # Determine if this API has read access for the provided permission
    # @param key - the key for the permission being queried
    # @returns - true if this API can read the passed permission, false otherwise
    def can_read?(key)
      return [20, 10].include?(@permissions[key])
    end

    # Determine if this API has write access for the provided permission
    # @param key - the key for the permission being queried
    # @returns - true if this API can write the passed permission, false otherwise
    def can_write?(key)
      return [20].include?(@permissions[key])
    end

    # Determine if this API is the API being used to make requests
    # @returns - true if this is the API being used, false otherwise
    def our_api?
      return @id == OSM::API.api_id
    end

  end


  class Grouping

    attr_reader :id, :name, :active

    # Initialize a new Grouping using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['patrolid']
      @name = data['name']
      @active = (data['active'] == 1)
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
      @start = OSM::make_datetime(data['startdate'], data['starttime'])
      @end = OSM::make_datetime(data['enddate'], data['endtime'])
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
      data = {} unless data.is_a?(Hash)

      @pending = (data['pending'] || {}).symbolize_keys
      @descriptions = (data['description'] || {}).symbolize_keys

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

    def empty?
      return @by_member.empty?
    end

  end


  private
  def self.make_array_of_symbols(array)
    array.each_with_index do |item, index|
      array[index] = item.to_sym
    end
  end

  def self.find_current_term_id(api, section_id, data={})
    terms = api.get_terms(data)
    unless terms.nil?
      terms.each do |term|
        return term.id if term.current? && (term.section_id == section_id)
      end
    end
    return nil
  end

  def self.make_datetime(date, time)
    if (!date.blank? && !time.blank?)
      return DateTime.parse((date + ' ' + time), 'yyyy-mm-dd hh:mm:ss')
    elsif !date.blank?
      return DateTime.parse(date, 'yyyy-mm-dd')
    else
      return nil
    end
  end

  def self.parse_date(date)
    begin
      return Date.parse(date, 'yyyy-mm-dd')
    rescue ArgumentError
      return nil
    end
  end


end
