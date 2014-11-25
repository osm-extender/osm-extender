show_meeting_summary = Hash[ Osm::Section.get_all(User.first.osm_api).map{ |s| [s.id, s.myscout_programme_summary?] } ]
cal = Icalendar::Calendar.new

@items.each do |item|
  if item.is_a?(Osm::Meeting)
    cancelled = item.title.include?('CANCELLED')
    start = item.date.strftime('%Y%m%d')
    finish = item.date.strftime('%Y%m%d')
    start += "T#{item.start_time.gsub(':', '')}00" if item.start_time
    finish += "T#{item.finish_time.gsub(':', '')}00" if item.finish_time

    cal.event do |e|
      e.dtstart = start
      e.dtend = finish
      e.summary = item.title
      e.description = item.notes_for_parents if show_meeting_summary[item.section_id]
      e.uid = "OSMX_SECTION-#{item.section_id}_MEETING-#{item.id}"
      e.transp = 'TRANSPARENT'
      e.status = (cancelled ? 'CANCELLED' : 'TENTATIVE')
    end
  elsif item.is_a?(Osm::Event)
    cancelled = item.name.include?('CANCELLED')
    cal.event do |e|
      if item.start.strftime('%H%M').eql?('0000') # no time set in OSM
        e.dtstart = Icalendar::Values::Date.new(item.start.to_date)
      else
        e.dtstart = item.start
      end
      if item.finish? # at least a finish date in in OSM
        if item.finish.strftime('%H%M').eql?('0000') # no time set in OSM
          e.dtend = Icalendar::Values::Date.new(item.finish.to_date)
        else
          e.dtend = item.finish
        end
      else # no finish date/time in OSM
        e.dtend = Icalendar::Values::Date.new(item.start)
      end
      e.summary = item.name
      e.location = item.location if item.location?
      e.description = ActionController::Base.helpers.strip_tags(item.public_notepad) if item.public_notepad?
      e.uid = "OSMX_SECTION-#{item.section_id}_EVENT-#{item.id}"
      e.transp = 'TRANSPARENT'
      e.status = (cancelled ? 'CANCELLED' : 'TENTATIVE')
    end
  end
end

cal.to_ical
