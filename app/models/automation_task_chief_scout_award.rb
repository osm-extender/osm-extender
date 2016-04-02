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
    badge_identifiers = Osm::ActivityBadge.get_badges_for_section(user.osm_api, section).map{ |i| [i.identifier, :activity] }
    badge_identifiers += Osm::StagedBadge.get_badges_for_section(user.osm_api, section).map{ |i| [i.identifier, :staged] }

    badge_summaries = Osm::Badge.get_summary_for_section(user.osm_api, section)
    badge_summaries.each do |badge_summary|
      count_for_member = 0


      # Count earnt badges
      badge_identifiers.each do |identifier, type|
        case badge_summary[identifier]
        when :awarded
          # Don't want to count staged badge awarded in previous section
          if type.eql?(:staged)
            member_date = member_start_dates[badge_summary[:member_id]]
            award_date = badge_summary["#{identifier}_date"]
            next identifier unless member_date.is_a?(Date) # Can't do the comparrison
            next identifier unless award_date.is_a?(Date)  # Can't do the comparrison
            next identifier if award_date < member_date    # Awarded before starting section
          end
        when :due
          # Nothing - we always want to count it
        else
          # Badge summary is not ina state we want to count
          next identifier
        end

        count_for_member += 1
      end # each identifier

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
      end

      # Update data value if it changed
      badge_data = member_badge_data[badge_summary[:member_id]]
      unless (badge_data.requirements[REQUIREMENT_IDS[section.type]] || '').eql?(set_data_to)
        badge_data.requirements[REQUIREMENT_IDS[section.type]] = set_data_to    
        if badge_data.update(user.osm_api)
          log_lines.push(["Updated data in OSM to \"#{set_data_to}\"."])
        else
          errors.push "Couldn't update #{badge_summary[:name]}'s data to \"#{set_data_to}\"."
        end
      end

    end # each badge_summary

    ret_val.merge(success: ret_val[:errors].empty?)
  end

end
