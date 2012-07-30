module Osm

  class Grouping

    attr_reader :id, :name, :active

    # Initialize a new Grouping using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = Osm::to_i_or_nil(data['patrolid'])
      @name = data['name']
      @active = (data['active'] == 1)
    end

  end

end
