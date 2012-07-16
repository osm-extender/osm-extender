module Osm

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

end
