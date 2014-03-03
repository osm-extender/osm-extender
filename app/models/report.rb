class Report

  def self.badge_completion_matrix(user, section, params)
    Rails.cache.fetch("user#{user.id}-report-badge_completion_matrix-data-#{params.inspect}", :expires_in => 10.minutes) do
      matrix = []
      names = []
      member_ids = []
  
      badges = []
      badges += Osm::CoreBadge.get_badges_for_section(user.osm_api, section) if params[:include_core]
      badges += Osm::StagedBadge.get_badges_for_section(user.osm_api, section) if params[:include_staged]
      badges += Osm::ChallengeBadge.get_badges_for_section(user.osm_api, section) if params[:include_challenge]
      badges += Osm::ActivityBadge.get_badges_for_section(user.osm_api, section) if params[:include_activity]
  
      unless badges.first.nil?
        data = badges.first.get_data_for_section(user.osm_api, section)
        names = data.map{ |i| "#{i.first_name} #{i.last_name}" }
        member_ids = data.map{ |i| i.member_id }
      end
  
      badges.each do |badge|
        unless ['nightsaway', 'hikes', 'adventure'].include?(badge.osm_key)
          completion_data = badge.get_data_for_section(user.osm_api, section)
          completion_data.sort!{ |a,b| member_ids.find_index(a.member_id) <=> member_ids.find_index(b.member_id) }
          badge.requirements.each do |requirement|
            requirement_group = requirement.field.split('_').first
            unless requirement_group.eql?('y')
              met_data = completion_data.map do |i|
                met = nil
                if badge.type.eql?(:staged) && i.awarded?
                  met = :awarded if requirement_group <= ' abcde'[i.awarded]
                  met ||= :completed if requirement_group.eql?(' abcde'[i.completed])
                else
                  met = :awarded if i.awarded?
                  met ||= :completed if i.completed?
                end
                if i.started?
                  unless badge.type.eql?(:staged) && !requirement_group.eql?(' abcde'[i.started])
                    value = i.requirements[requirement.field]
                    if value.blank? || value.to_s[0].downcase.eql?('x')
                      if (i.total_gained < badge.total_needed) || (i.gained_in_sections[requirement_group] < (badge.needed_from_section[requirement_group] || 0))
                        met = :no
                      else
                        met = :not_needed
                      end
                    else
                      met = :yes
                    end
                  end
                end #started?
                met || :not_started
              end
  
              matrix.push ([
                badge.type,
                badge.name,
                (badge.type.eql?(:staged) ? 'abcde'.index(requirement_group)+1 : requirement_group),
                requirement.name,
                *met_data,
              ])
            end
          end # each badge.requirement
        end
      end # each badge
  
      [names, matrix]
    end
  end

  def self.calendar(user, params)
    Rails.cache.fetch("user#{user.id}-report-calendar-data-#{params.inspect}", :expires_in => 10.minutes) do
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
      
      items.sort!{ |i1, i2| i1[0] <=> i2[0] }
      items.map{ |i| i[1]}
    end
  end


  def self.event_attendance(user, section, events, groupings)
    Rails.cache.fetch("3user#{user.id}-report-event_attendance-data-#{user.id}-#{section.id}-#{events.inspect}-#{groupings.inspect}", :expires_in => 10.minutes) do
      event_names = []
      row_groups = {}
      member_totals = {}
      event_totals = {:yes=>[], :no=>[], :invited=>[], :shown=>[], :reserved=>[]}
      all_events = Osm::Event.get_for_section(user.osm_api, section)
      all_events.select{|e| events.include?(e.id)}.sort.each do |event|
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
