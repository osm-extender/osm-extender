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
        unless ['nightsaway', 'hikes', 'timeonthewater', 'adventure'].include?(badge.osm_key)
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

  def self.calendar(user, options)
    Rails.cache.fetch("user#{user.id}-report-calendar-data-#{options.inspect}", :expires_in => 10.minutes) do
      items = []

      sections = Osm::Section.get_all(user.osm_api)
      sections.select!{ |s| s.youth_section? || s.adults? }
      sections.each do |section|
        these_options = options.merge({
          include_events: options[:events][section.id.to_s].eql?('1'),
          include_meetings: options[:programme][section.id.to_s].eql?('1'),
        })

        these_items = get_calendar_items_for_section(user.osm_api, section, these_options)

        these_items[:events].each do |event|
          items.push [event.start, event]
        end
        these_items[:meetings].each do |meeting|
          items.push [meeting.date, meeting]
        end
      end

      items.sort!{ |i1, i2| i1[0] <=> i2[0] }
      items.map{ |i| i[1]}
    end
  end


  def self.event_attendance(user, section, events, groupings)
    Rails.cache.fetch("user#{user.id}-report-event_attendance-data-#{user.id}-#{section.id}-#{events.inspect}-#{groupings.inspect}", :expires_in => 10.minutes) do
      event_names = []
      row_groups = {}
      member_totals = {}
      event_totals = {:yes=>[], :no=>[], :invited=>[], :shown=>[], :reserved=>[]}
      events.map{ |id| Osm::Event.get(user.osm_api, section, id) }.sort.each do |event|
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

  # options Hash includes:
  # :start [Date] - start date
  # :finish [Date] - finish date
  # :include_meetings [Boolean]
  # :include_events [Boolean]
  # @return [Hash]
  def self.get_calendar_items_for_section(api, section, options)
    [:start, :finish, :include_meetings, :include_events].each do |attr|
      raise ArgumentError, "options doesn't contain a value for :#{attr}" unless options.has_key?(attr)
    end

    # Fetch options
    start = options[:start]
    finish = options[:finish]
    include_meetings = !!options[:include_meetings]
    include_events = !!options[:include_events]

    # Stuff we'll return
    meetings = []
    events = []

    # Fetch terms
    terms = Osm::Term.get_for_section(api, section)
    terms.select!{ |term| !(term.finish < start) && !(term.start > finish) }

    # Fetch meetings
    if include_meetings
      terms.each do |term|
        these_meetings = Osm::Meeting.get_for_section(api, section, term)
        these_meetings.select!{ |meeting| (meeting.date >= start) && (meeting.date <= finish) }
        meetings.push(*these_meetings)
        meetings.sort!
      end
    end

    # Fetch events
    if include_events
      events = Osm::Event.get_list(api, section)
      events.select!{ |e|  (e[:start] >= start) && (e[:start] <= finish) }
      events.map!{ |e| Osm::Event.get(api, section, e[:id]) }
      events.sort!
    end

    return {
      meetings: meetings,
      events: events,
    }
  end

end
