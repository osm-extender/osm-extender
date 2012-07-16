module Osm

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
      @sections = Osm::make_array_of_symbols(data['sections'] || [])
      @tags = data['tags'] || []
      @files = data['files']
      @badges = data['badges']
    end

  end

end
