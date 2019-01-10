class PlannedBadgeRequirementsReport < LongRunningReport
  def self.data_for?(user_id, section_id, start:, finish:, check_earnt:, check_stock:, check_participation:, check_birthday:, check_event_attendance:, check_meeting_attendance:)
    cache_key = "#{self.name}-a-#{user_id}-#{section_id}-#{start}-#{finish}-"
                + [check_earnt, check_stock, check_participation, check_birthday, check_event_attendance, check_meeting_attendance]
                  .map { |v| v ? 't' : 'f' }.join
    Rails.cache.exist?(cache_key)
  end

  def self.data_for(user_id, section_id, start:, finish:, check_earnt:, check_stock:, check_participation:, check_birthday:, check_event_attendance:, check_meeting_attendance:)
    cache_key = "#{self.name}-a-#{user_id}-#{section_id}-#{start}-#{finish}-"
                + [check_earnt, check_stock, check_participation, check_birthday, check_event_attendance, check_meeting_attendance]
                  .map { |v| v ? 't' : 'f' }.join

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      user = User.find(user_id)
      osm_api = user.osm_api
      section = Osm::Section.get(osm_api, section_id)

      badge_stock = check_stock ? Osm::Badges.get_stock(osm_api, section) : {}
      badge_stock.default = 0

      badge_by_type = {
        'activity' => Osm::ActivityBadge,
        'staged' => Osm::StagedBadge,
        'challenge' => Osm::ChallengeBadge,
        'core' => Osm::CoreBadge,
      }

      by_badge = {}
      by_meeting = {}
      by_event = {}
      all_requirements = {} # key is an Osm::Meeting or Osm::Event, value is array f hashes of the information
      meeting_attendance = {} # Key is member ID, value is the combined Hash of attendance dates
      event_attendance = {} # Key is member ID, value is a Hash of event ID to attending symbol
      earnt_badges = {}

      terms = Osm::Term.get_for_section(osm_api, section).select{ |term| !(term.finish < start) && !(term.start > finish) }
      events, meetings = Report.get_calendar_items_for_section(osm_api, section, start: start, finish: finish, include_events: section.subscription_at_least?(:silver), include_meetings: true).values_at(:events, :meetings)


      # For events
      events.each do |event|
        # Get badge requirements
        by_event[event] ||= {} unless event.badges.empty?
        all_requirements[event] ||= []
        event.badges.each do |bl|
          next unless bl.badge_section.eql?(section.type)
          badge_name = "#{bl.badge_name.downcase.capitalize} #{bl.badge_type.to_s.titleize} badge"
          requirement_name = bl.requirement_label
          by_badge[badge_name] ||= []
          by_badge[badge_name].push requirement_name unless by_badge[badge_name].include?(requirement_name)
          by_event[event][badge_name] ||= []
          by_event[event][badge_name].push requirement_name unless by_event[event][badge_name].include?(requirement_name)
          all_requirements[event].push({column: bl.requirement_id, data: (bl.data.blank? ? 'YES' : bl.data)})
        end # each bl
        # Get attendance
        if check_event_attendance && check_earnt
          terms.each do |term| # Make sure we get people who have left but are still attending
            event.get_attendance(osm_api, term).each do |attendance|
              event_attendance[attendance.member_id] ||= {}
              event_attendance[attendance.member_id][event.id] = attendance.attending
            end # each attendance
          end # each term
        end
      end # each event

      # For meetings
      meetings.each do |meeting|
        badge_links = meeting.get_badge_requirements(osm_api)
        all_requirements[meeting] ||= [] unless badge_links.empty?
        badge_links.each do |bl|
          badge_name = "#{bl['badgeName'].downcase.capitalize} #{bl['badgetype'].to_s.titleize} badge"
          requirement_name = "#{bl['columngroup']}: #{bl['name']}"
          by_meeting[meeting] ||= {}
          by_meeting[meeting][badge_name] ||= []
          by_meeting[meeting][badge_name].push requirement_name unless by_meeting[meeting][badge_name].include?(requirement_name)
          by_badge[badge_name] ||= []
          by_badge[badge_name].push requirement_name unless by_badge[badge_name].include?(requirement_name)
          all_requirements[meeting].push({column: bl['column_id'].to_i, data: (bl['data'].blank? ? 'YES' : bl['data'])})
        end
      end # meetings for section
      # Get attendance
      if check_meeting_attendance && check_earnt
        terms.each do |term|
          Osm::Register.get_attendance(osm_api, section, term).each do |attendance_data|
            meeting_attendance[attendance_data.member_id] ||= {}
            meeting_attendance[attendance_data.member_id].merge!(attendance_data.attendance)
          end # each attendance_data
        end # each term
      end

      if check_earnt
        # Get badges and datas
        badges = [Osm::CoreBadge, Osm::ActivityBadge, Osm::StagedBadge, Osm::ChallengeBadge].map{ |klass| klass.get_badges_for_section(osm_api, section) }.flatten
        badges.select!{ |b| !b.add_columns? }
        datas = {} # key = "#{badge_id}_#{badge_version}" value = Array of datas
        requirements = {} # key = member_id value = shared requirements Hash
        badges.select{ |b| b.requirements.size > 0 }.each do |badge| # Each badge with requirements
          badge.get_data_for_section(osm_api, section).each do |data|
            # All datas for a member share a requirements hash 
            requirements[data.member_id] ||= DirtyHashy.new
            requirements[data.member_id].merge!(data.requirements)
            data.requirements = requirements[data.member_id]
            # Add the data to the collection
            datas[badge.identifier] ||= []
            datas[badge.identifier].push data
          end
        end

        # Fast forward badge requirements
        all_requirements.each do |thing, list|
          list.each do |requirement| # {column: ###, data: 'YES'}
            requirements.each do |member_id, data|
              if thing.is_a?(Osm::Meeting) && check_meeting_attendance
                next unless [nil, :yes].include?(meeting_attendance[member_id][thing.date]) # They were present or attendance was not taken (yet)
              elsif thing.is_a?(Osm::Event) && check_event_attendance
                next unless [:yes, :invited, :shown, :reserved].include?(event_attendance[member_id][thing.id]) # They may be present
              end
              data[requirement[:column]] = requirement[:data]
            end # each entry in requirements by member
          end # list of requirements
        end # all_requirements.each

        # Get list of finished badges
        datas.each do |badge_identifier, list|
          list.each do |data|
            next if data.awarded? || data.due?
            if data.earnt?
              member_name = "#{data.first_name} #{data.last_name}"
              key = [data.badge, data.earnt]
              earnt_badges[key] ||= []
              earnt_badges[key].push member_name
            end
          end
        end

        if check_participation
          badge = badges.select{ |b| b.name == 'Joining In' }.first
          unless badge.nil?
            (members ||= Osm::Member.get_for_section(osm_api, section)).each do |member|
              next if member.grouping_id == -2  # Leaders don't get these participation badges
              next_level_due = ((start.to_time - member.joined_movement.to_time) / 1.year).ceil
              if (start..finish).include?(member.joined_movement + next_level_due.years)
                key = [badge, next_level_due]
                earnt_badges[key] ||= []
                earnt_badges[key].push member.name
              end
            end
          end
        end # if check_participation

        if check_birthday
          birthday_badges = Hash[badges.select{ |b| !!b.name.match(/birthday/i) }.map{ |b| [b.name.match(/(\d+)(?:st|nd|th)/)[1].to_i, b] }]
          (members ||= Osm::Member.get_for_section(osm_api, section)).each do |member|
            next_birthday = ((start.to_time - member.date_of_birth.to_time) / 1.year).ceil
            if (start..finish).include?(member.date_of_birth + next_birthday.years)
              badge = birthday_badges[next_birthday]
              unless badge.nil?
                key = [badge, 1]
                earnt_badges[key] ||= []
                earnt_badges[key].push member.name
              end
            end
          end
        end # check_birthday
      end # if check_earnt

      {
        start: start,
        finish: finish,
        by_badge: by_badge,
        by_meeting: by_meeting,
        by_event: by_event,
        check_earnt: check_earnt,
        earnt_badges: earnt_badges,
        badge_stock: badge_stock,
      }
    end
  end
end
