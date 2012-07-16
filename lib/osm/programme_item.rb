module Osm

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
          @activities.push Osm::ProgrammeActivity.new(item)
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

end
