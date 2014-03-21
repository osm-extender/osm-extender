show_meeting_summary = Hash[ Osm::Section.get_all(User.first.osm_api).map{ |s| [s.id, s.myscout_programme_summary?] } ]
cal = Icalendar::Calendar.new

@items.each do |item|
  if item.is_a?(Osm::Meeting)
    cancelled = item.title.include?('CANCELLED')
    start = item.date.strftime('%Y%m%d')
    finish = item.date.strftime('%Y%m%d')
    start += "T#{item.start_time.gsub(':', '')}00" if item.start_time
    finish += "T#{item.finish_time.gsub(':', '')}00" if item.finish_time

    cal.event do
      dtstart start
      dtend finish
      summary item.title
      description item.notes_for_parents if show_meeting_summary[item.section_id]
      uid "OSMX_SECTION-#{item.section_id}_MEETING-#{item.id}"
      transp 'TRANSPARENT'
      status (cancelled ? 'CANCELLED' : 'TENTATIVE')
    end
  elsif item.is_a?(Osm::Event)
    cancelled = item.name.include?('CANCELLED')
    cal.event do
      if item.start.strftime('%H%M').eql?('0000') # no time set in OSM
        dtstart item.start.strftime('%Y%m%d'), {'VALUE' => 'DATE'}
      else
        dtstart item.start
      end
      if item.finish? # at least a finish date in in OSM
        if item.finish.strftime('%H%M').eql?('0000') # no time set in OSM
          dtend item.finish.next_day.strftime('%Y%m%d'), {'VALUE' => 'DATE'}
        else
          dtend item.finish
        end
      else # no finish date/time in OSM
        dtend item.start.next_day.strftime('%Y%m%d'), {'VALUE' => 'DATE'}
      end
      summary item.name
      location(item.location, {'LANGUAGE' => 'en'}) if item.location?
      description ActionController::Base.helpers.strip_tags(item.public_notepad) if item.public_notepad?
      uid "OSMX_SECTION-#{item.section_id}_EVENT-#{item.id}_A"
      transp 'TRANSPARENT'
      status (cancelled ? 'CANCELLED' : 'TENTATIVE')
    end
  end
end

cal.to_ical
