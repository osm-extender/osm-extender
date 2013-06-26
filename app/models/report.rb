class Report

  def self.calendar(user, params)
    Rails.cache.fetch("user#{user.id}-report-calendar-data-#{params.inspect}", :expires_in => 5.minutes) do
      items = []
      Osm::Section.get_all(user.osm_api).select{ |s| s.youth_section? || s.adults? }.each do |section|
        if params[:events][section.id.to_s].eql?('1')
          Osm::Event.get_for_section(user.osm_api, section).each do |event|
            unless event.start.nil?
              event_date = event.finish.nil? ? event.start : event.finish
              unless (event_date < params[:calendar_start]) || (event_date > params[:calendar_finish])
                items.push [event_date, event]
              end
            end
          end
        end
  
        if params[:programme][section.id.to_s].eql?('1')
          Osm::Term.get_for_section(user.osm_api, section).each do |term|
            unless term.before?(params[:calendar_start]) || term.after?(params[:calendar_finish])
              Osm::Meeting.get_for_section(user.osm_api, section, term).each do |meeting|
                unless (meeting.date < params[:calendar_start]) || (meeting.date > params[:calendar_finish])
                  items.push [meeting.date, meeting]
                end
              end
            end
          end
        end
      end
      
      items.sort!{ |i1, i2| i1[0] <=> i2[0] }
      items.map{ |i| i[1]}
    end
  end


  def self.event_attendance(user, section, events, groupings)
    Rails.cache.fetch("user#{user.id}-report-event_attendance-data-#{user.id}-#{section.id}-#{events.inspect}-#{groupings.inspect}", :expires_in => 5.minutes) do
      event_names = []
      row_groups = {}
      member_totals = {}
      event_totals = {:yes=>[], :no=>[], :invited=>[], :shown=>[], :reserved=>[]}
      events.each do |event_id|
        event = Osm::Event.get(user.osm_api, section, event_id.to_i)
        this_event_totals = {:yes=>0, :no=>0, :invited=>0, :shown=>0, :reserved=>0}
        event.get_attendance(user.osm_api).each do |attendance|
          if groupings.include?(attendance.grouping_id)
            row_groups[attendance.grouping_id] ||= {}
            row_groups[attendance.grouping_id][attendance.member_id] ||= []
            row_groups[attendance.grouping_id][attendance.member_id].push attendance
            member_totals[attendance.member_id] ||= {:yes=>0, :no=>0, :invited=>0, :shown=>0, :reserved=>0}
            member_totals[attendance.member_id][attendance.attending] += 1 unless member_totals[attendance.member_id][attendance.attending].nil?
            this_event_totals[attendance.attending] += 1 unless this_event_totals[attendance.attending].nil?
          end
        end
        event_names.push event.name
        event_totals[:yes].push this_event_totals[:yes]
        event_totals[:no].push this_event_totals[:no]
        event_totals[:invited].push this_event_totals[:invited]
        event_totals[:shown].push this_event_totals[:shown]
        event_totals[:reserved].push this_event_totals[:reserved]
      end
      
      {
        :event_names => event_names,
        :row_groups => row_groups,
        :event_totals => event_totals,
        :member_totals => member_totals,
      }
    end
  end

end