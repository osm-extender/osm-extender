module Osm

  class Event

    attr_reader :id, :section_id, :name, :start, :end, :cost, :location, :notes

    # Initialize a new Event using the hash returned by the API call
    # @param data the hash of data for the object returned by the API
    def initialize(data)
      @id = Osm::to_i_or_nil(data['eventid'])
      @section_id = Osm::to_i_or_nil(data['sectionid'])
      @name = data['name']
      @start = Osm::make_datetime(data['startdate'], data['starttime'])
      @end = Osm::make_datetime(data['enddate'], data['endtime'])
      @cost = data['cost']
      @location = data['location']
      @notes = data['notes']
    end

  end

end
