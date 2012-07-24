module Osm

  class ApiAccess

    attr_reader :id, :name, :permissions

    # Initialize a new API Access using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = data['apiid'].to_i
      @name = data['name']
      @permissions = data['permissions'] || {}

      # Rubyfy permissions hash
      @permissions.keys.each do |key|
        @permissions[key] = @permissions[key].to_i
        @permissions[(key.to_sym rescue key) || key] = @permissions.delete(key) # Symbolize key
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
      return @id == Osm::Api.api_id
    end

  end

end
