class AutomationTaskChiefScoutAward < AutomationTask

  ALLOWED_SECTIONS = [:beavers, :cubs, :scouts]

  BADGE_COUNTS = {
    beavers: 4,
    cubs: 6,
    scouts: 6
  }

  BADGE_IDS = {
    beavers: 1529,
    cubs: 1587,
    scouts: 1539
  }

  REQUIREMENT_IDS = {
    beavers: 114257,
    cubs: 114603,
    scouts: 114339
  }

 ACHIEVED_ACTIONS = [
    '{COUNT-OF-BADGES} of {BADGES-NEEDED}',
    '{COUNT-OF-BADGES}',
    '[YES]',
  ]

  UNACHIEVED_ACTIONS = [
    'x{COUNT-OF-BADGES} of {BADGES-NEEDED}',
    'x{COUNT-OF-BADGES}',
    'Progress bar',
    'Nothing',
  ]


  def self.required_permissions
    [ [:write, :badge], [:read, :member] ]
  end

  def self.configuration_labels
    {
      unachieved_action: "When it's not achieved set the badges column to:",
      achieved_action: "When it's achieved set the badges column to:",
    }
  end

  def self.default_configuration
    {
      unachieved_action: 0,
      achieved_action: 0,
    }
  end

  def self.configuration_types
    {
      unachieved_action: :positive_integer,
      achieved_action: :positive_integer,
    }
  end

  def self.human_name
    "Chief Scout's award"
  end

  def human_configuration
    "Set badges column to \"#{ACHIEVED_ACTIONS[configuration[:achieved_action]]}\" or \"#{UNACHIEVED_ACTIONS[configuration[:unachieved_action]]}\"."
  end



  private
  def perform_task(user=self.user)
    ret_val = {log_lines: log_lines=[], errors: errors=[]}

    section = Osm::Section.get(user.osm_api, section_id)
    if section.nil?
      return {success: false, errors: ['Could not retrieve section from OSM.']}
    end
    
    badge = Osm::ChallengeBadge.get_badges_for_section(user.osm_api, section) || []
    badge = badge.select{ |b| b.id.eql?(BADGE_IDS[section.type]) }.first
    if badge.nil?
      return {success: false, errors: ["Could not retrieve Chief Scout's Award badge from OSM."]}
    end
    member_badge_data = Hash[badge.get_data_for_section(user.osm_api, section).map{ |d| [d.member_id, d] } ]

    member_start_dates = Hash[ Osm::Member.get_for_section(user.osm_api, section).map{ |m| [m.id, m.started_section] } ]
    activity_badges = Hash[ Osm::ActivityBadge.get_badges_for_section(user.osm_api, section).map{ |b| [b.identifier, b] } ]
    staged_badges = Hash[ Osm::StagedBadge.get_badges_for_section(user.osm_api, section).map{ |b| [b.identifier, b] } ]

    badge_summaries = Osm::Badge.get_summary_for_section(user.osm_api, section)
    badge_summaries.each do |badge_summary|
      count_for_member = 0

      activity_badges.keys.each do |identifier|
        if [:awarded, :due].include?(badge_summary[identifier])
          count_for_member += 1
        end        
      end # each activity badge identifier

      staged_badges.keys.each do |identifier|
        if badge_summary[identifier].eql?(:awarded)
          # Don't want to count staged badge awarded in previous section
          start_date = member_start_dates[badge_summary[:member_id]]
          award_date = badge_summary["#{identifier}_date"]

          unless start_date.is_a?(Date) # Can't do the comparrison
            errors.push "Couldn't get started section date for #{badge_summary[:name]}."
            next identifier
          end
          unless award_date.is_a?(Date)  # Can't do the comparrison
            errors.push "Couldn't get awarded date for #{badge_summary[:name]}'s #{staged_badges[identifier].name} badge."
            next identifier
          end

          if start_date <= award_date    # Awarded after starting section
            count_for_member += 1
          end

        elsif badge_summary[identifier].eql?(:due)
          # Always want to count a due badge
          count_for_member += 1
        end
      end # each staged badge identifier

      log_lines.push "#{badge_summary[:name]} has achieved #{count_for_member} of #{BADGE_COUNTS[section.type]} activity/staged activity badges."

      set_data_to = ''
      if count_for_member >= BADGE_COUNTS[section.type]
        # Member has achieved required number of badges since joining section
        case configuration[:achieved_action]
        when 0
          set_data_to = "#{count_for_member} of #{BADGE_COUNTS[section.type]}"
        when 1
          set_data_to = "#{count_for_member}"
        when 2
          set_data_to = '[YES]'
        end

      else
        # Member has NOT achieved required number of badges since joining section
        case configuration[:unachieved_action]
        when 0
          set_data_to = "x#{count_for_member} of #{BADGE_COUNTS[section.type]}"
        when 1
          set_data_to = "x#{count_for_member}"
        when 2 # Progress bar
          if count_for_member > 0
            set_data_to = "#{'x' * count_for_member}#{'_' * (BADGE_COUNTS[section.type] - count_for_member)}"
          end
        when 3
          set_data_to = ''
        end

      end # if achieved

      # Update data value if it changed
      badge_data = member_badge_data[badge_summary[:member_id]]
      unless (badge_data.requirements[REQUIREMENT_IDS[section.type]] || '').eql?(set_data_to)
        badge_data.requirements[REQUIREMENT_IDS[section.type]] = set_data_to    
        begin
          if badge_data.update(user.osm_api)
            log_lines.push(["Updated data in OSM to \"#{set_data_to}\"."])
          else
            errors.push "Couldn't update #{badge_summary[:name]}'s data to \"#{set_data_to}\"."
          end
        rescue Osm::Error => exception
          errors.push "Couldn't update #{badge_summary[:name]}'s data to \"#{set_data_to}\". OSM said \"#{exception.message}\"."
        end
      end

    end # each badge_summary

    ret_val.merge(success: ret_val[:errors].empty?)
  end

end
