class Report

  def self.badge_completion_matrix(user, section, options)
    Rails.cache.fetch("user#{user.id}-report-badge_completion_matrix-data-#{options.inspect}", :expires_in => 10.minutes) do
      matrix = []
      names = []
      member_ids = []

      badges = []
      badges += Osm::CoreBadge.get_badges_for_section(user.osm_api, section) if options[:include_core]
      badges += Osm::StagedBadge.get_badges_for_section(user.osm_api, section) if options[:include_staged]
      badges += Osm::ChallengeBadge.get_badges_for_section(user.osm_api, section) if options[:include_challenge]
      badges += Osm::ActivityBadge.get_badges_for_section(user.osm_api, section) if options[:include_activity]
      badges.select!{ |b| !b.add_columns? } # Skip badges we add columns to

      unless badges.first.nil?
        data = badges.first.get_data_for_section(user.osm_api, section)
        names = data.map{ |i| "#{i.first_name} #{i.last_name}" }
        member_ids = data.map{ |i| i.member_id }
      end

      # Exclude any badges matching the criteria
      if options[:exclude_not_started] || options[:exclude_all_finished]
        summary = Osm::Badge.get_summary_for_section(user.osm_api, section)
        started = Hash.new(0)  # Count of people who have started each badge
        finished = Hash.new(0) # Count of people who have finished each badge
        summary.each do |member|
          member.keys.select{ |k| !!k.match(/\d+_\d+/)}.each do |key| # Keys which relate to badge information
            started[key] += 1 if member[key].eql?(:started)
            finished[key] += 1 if [:due, :awarded].include?(member[key])
          end
        end # each member in summary

        badges.select! do |badge|
          exclude = false
          if options[:exclude_not_started]
            # exclude the badge if noone has started it
            exclude ||= started[badge.identifier].eql?(0)
          end
          if options[:exclude_all_finished]
            # exclude the badge if everyone has finished it
            exclude ||= finished[badge.identifier].eql?(summary.count)
          end
          !exclude
        end
      end

      # Get badge data
      badges.each do |badge|
        completion_data = badge.get_data_for_section(user.osm_api, section)
        completion_data.sort!{ |a,b| member_ids.find_index(a.member_id) <=> member_ids.find_index(b.member_id) }
        badge.requirements.each do |requirement|
          met_data = completion_data.map do |i|
            met = nil

            # Workout if badge is completed or awarded
            if badge.has_levels? # Staged
              met = :awarded if requirement.mod.letter < ('a'..'z').to_a[i.awarded]
              met ||= :completed if requirement.mod.letter.eql?(('a'..'z').to_a[i.earnt - 1])
            else # 'Normal'
              met = :awarded if i.awarded?
              met ||= :completed if i.earnt?
            end

            # Workout if the requirmeent is needed to complete the badge (if started)
            if met.nil? && i.started?
              unless badge.has_levels? && !requirement.mod.letter.eql?(('a'..'z').to_a[i.started - 1])
                if i.requirement_met?(requirement.id)
                  met = :yes
                else
                  # Requirement not met but is it actually needed?
                  needed_for_total = (i.total_gained < badge.min_requirements_required)
                  modules_gained = i.modules_gained
                  needed_for_module_total = (modules_gained.size < badge.min_modules_required)
                  needed_for_module = !modules_gained.include?(requirement.mod.letter)
                  modules_needed = i.badge.requires_modules.nil? ? [] : i.badge.requires_modules.select{ |a| !a.map{ |b| modules_gained.include?(b) }.include?(true) }.flatten
                  if needed_for_total || (needed_for_module && needed_for_module_total) || (needed_for_module && modules_needed.include?(requirement.mod.letter))
                    met = :no
                  else
                    met = :not_needed
                  end
                end
              end
            end #started?
            met || :not_started
          end

          matrix.push ([
            badge.type,
            badge.name,
            (badge.has_levels? ? ('a'..'z').to_a.index(requirement.mod.letter)+1 : requirement.mod.letter),
            requirement.name,
            *met_data,
          ])
        end # each badge.requirement
      end # each badge

      {names: names, matrix: matrix}
    end
  end

  def self.badge_stock_check(user, section, options)
    Rails.cache.fetch("user#{user.id}-report-badge_stock_check-data-#{options.inspect}", :expires_in => 10.minutes) do

      badges = []
      badges += Osm::CoreBadge.get_badges_for_section(user.osm_api, section) if options[:include_core]
      badges += Osm::StagedBadge.get_badges_for_section(user.osm_api, section) if options[:include_staged]
      badges += Osm::ChallengeBadge.get_badges_for_section(user.osm_api, section) if options[:include_challenge]
      badges += Osm::ActivityBadge.get_badges_for_section(user.osm_api, section) if options[:include_activity]

      stock = Osm::Badges.get_stock(user.osm_api, section)
      stock.default = 0

      data = [] # Contains [badge_type, badge_group, badge.name, level, stock]

      badges.each do |badge|
        badge_group = badge.group_name.empty? ? nil : badge.group_name
        this_data = [badge.type.to_s.titleize, badge_group, badge.name]

        if badge.levels?
          badge.levels.each do |level|
            next level if level < 1
            data.push this_data + [level, stock["#{badge.id}_#{level}"]]
          end # each level
        else # has no levels
          data.push this_data + [nil, stock["#{badge.id}_1"]]
        end # has levels?
      end # each badge

      # Remove badges with no stock if the hide_no_stock option is selected
      data.select!{ |i| i[4] > 0 } if options[:hide_no_stock]

      return data
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
