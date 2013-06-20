class Report

  def self.calendar(user, params)
    Rails.cache.fetch("user#{user.id}-report-calendar-data-#{params.inspect}", :expires_in => 5.minutes) do
      items = []
      Osm::Section.get_all(user.osm_api).select{ |s| s.youth_section? || s.adults? }.each do |section|
        if params[:events][section.id.to_s].eql?('1')
          Osm::Event.get_for_section(user.osm_api, section).each do |event|
            unless event.start.nil?
              event_date = event.finish.nil? ? event.start : event.finish
              unless (event_date < params[:start]) || (event_date > params[:finish])
                items.push [event_date, event]
              end
            end
          end
        end
  
        if params[:programme][section.id.to_s].eql?('1')
          Osm::Term.get_for_section(user.osm_api, section).each do |term|
            unless term.before?(params[:start]) || term.after?(params[:finish])
              Osm::Meeting.get_for_section(user.osm_api, section, term).each do |meeting|
                unless (meeting.date < params[:start]) || (meeting.date > params[:finish])
                  items.push [meeting.date, meeting]
                end
              end
            end
          end
        end
      end
      
      items.sort!{ |i1, i2| i1 <=> i2 }
      items.map{ |i| i[1]}
    end
  end

end