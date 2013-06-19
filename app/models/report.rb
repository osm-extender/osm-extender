class Report

  def self.calendar(user, params)
    (start, finish) = [Osm.parse_date(params[:calendar_start]), Osm.parse_date(params[:calendar_finish])].sort
    items = []
    Osm::Section.get_all(user.osm_api).select{ |s| s.youth_section? || s.adults? }.each do |section|
      if params[:events][section.id.to_s].eql?('1')
        Osm::Event.get_for_section(user.osm_api, section).each do |event|
          unless event.start.nil?
            event_date = event.finish.nil? ? event.start : event.finish
            unless (event_date < start) || (event_date > finish)
              items.push [event_date, event]
            end
          end
        end
      end

      if params[:programme][section.id.to_s].eql?('1')
        Osm::Term.get_for_section(user.osm_api, section).each do |term|
          unless term.before?(start) || term.after?(finish)
            Osm::Meeting.get_for_section(user.osm_api, section, term).each do |meeting|
              unless (meeting.date < start) || (meeting.date > finish)
                items.push [meeting.date, meeting]
              end
            end
          end
        end
      end
    end
    
    items.sort!{ |i1, i2| i1 <=> i2 }
    items.map!{ |i| i[1]}
    return items
  end

end