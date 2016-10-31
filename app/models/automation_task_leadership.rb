class AutomationTaskLeadership < AutomationTask

  ALLOWED_SECTIONS = [:cubs, :scouts]

  ROLES = {
    cubs: ['Normal member', 'Seconder', 'Sixer', 'Senior Sixer'],
    scouts: ['Normal member', 'Assistant Patrol Leader', 'Patrol Leader', 'Senior Patrol Leader'],
  }

  BADGE_IDS = {
    cubs: [nil, 186, 185, 187],
    scouts: [nil, 91, 90, 92],
  }

  def self.required_permissions
    [ [:write, :member], [:write, :badge] ]
  end

  def self.configuration_labels
    {
    }
  end

  def self.default_configuration
    {
    }
  end

  def self.configuration_types
    {
    }
  end

  def self.human_name
    "Leadership badges"
  end

  def human_configuration
    "The highest leadership level from personal details or awarded badges will result in the other being updated."
  end



  private
  def perform_task(user=self.user)
    ret_val = {log_lines: log_lines=[], errors: errors=[]}

    section = Osm::Section.get(user.osm_api, section_id)
    if section.nil?
      return {success: false, errors: ['Could not retrieve section from OSM.']}
    end

    members = []
    begin
      members= Osm::Member.get_for_section(user.osm_api, section)
    rescue Osm::Error::NoCurrentTerm => exception
      return {success: false, errors: ["The section doesn't have a current term."]}
    end

    core_badges = []
    begin
      core_badges = Osm::CoreBadge.get_badges_for_section(user.osm_api, section)
      if core_badges.nil? || core_badges.empty?
        return {success: false, errors: ['Could not retrieve core badges from OSM.']}
      end
      core_badges = Hash[ core_badges.select{ |b| BADGE_IDS[section.type].include?(b.id) }.map{ |b| [b.id, b] } ]
    rescue ArgumentError => exception
      intercept_messages = ["That badge does't exist (bad ID).", "That badge does't exist (bad version)."]
      if intercept_messages.include?(exception.mnessage)
        return {success: false, errors: ["Could not find the leadership badges under core badges in OSM."]}
      else
        raise exception
      end
    end
    leadership_badges = BADGE_IDS[section.type].map{ |i| core_badges[i] }
    leadership_badge_datas = leadership_badges.select{ |b| !b.nil? }
    leadership_badge_datas = Hash[ leadership_badge_datas.map{ |b| [b.id, Hash[ b.get_data_for_section(user.osm_api, section).map{ |d| [d.member_id, d] } ]] } ]

    members.each do |member|
      next member if member.leader?
      # Get leadership level from personal details
      pd_level = member.grouping_leader || 0

      # Get leadership level from badges
      bd_level = 0
      leadership_badges.each_with_index do |badge, idx|
        next badge if badge.nil?
        datas = leadership_badge_datas[badge.id]
        next badge if datas.nil?
        data = datas[member.id]
        next badge if data.nil?
 
        if data.awarded? || data.due?
          bd_level = idx
        end
      end # each leadership_badges

      # Get highest level
      level = [pd_level, bd_level].max
      log_lines.push "#{member.name} is a \"#{ROLES[section.type][level]}\"."

      if level > 0
         log_lines.push(member_lines = [])

        # Update personal details
        if level > pd_level
          member.grouping_leader = level
          begin
            if member.update(user.osm_api)
              member_lines.push "Updated personal details."
            else
              member_lines.push "Couldn't update personal details."
              errors.push "Couldn't update personal details for #{member.name}."
            end
          rescue Osm::Error => exception
            member_lines.push "Couldn't update personal details. OSM said \"#{exception.message}\"."
            errors.push "Couldn't update personal details for #{member.name}. OSM said \"#{exception.message}\"."
          end
        end # Update personal details

        # Mark badge as due
        if level > bd_level
          badge = leadership_badges[level]
          unless badge.nil?
            badge_data = leadership_badge_datas[BADGE_IDS[section.type][level]][member.id]
            unless badge_data.nil?
              begin
                if badge_data.mark_due(user.osm_api)
                  member_lines.push "Marked the \"#{badge.name}\" badge as due."
                else
                  member_lines.push "Couldn't mark the \"#{badge.name}\" badge as due."
                  errors.push "Couldn't mark badge as due for \"#{badge.name}\" & \"#{member.name}\"."
                end
              rescue Osm::Error => exception
                member_lines.push "Couldn't mark the \"#{badge.name}\" badge as due. OSM said \"#{exception.message}\"."
                errors.push "Couldn't mark badge as due for \"#{badge.name}\" & \"#{member.name}\". OSM said \"#{exception.message}\"."
              end
            else
              member_lines.push "Couldn't mark the \"#{badge.name}\" badge as due - couldn't find badge data for #{member.name}."
              errors.push "Couldn't find badge data for \"#{badge.name}\" & \"#{member.name}\""
            end

          else
            member_lines.push "Couldn't mark the badge as due - couldn't find it in OSM."
            message = "Couldn't find the #{ROLES[section.type][level]} badge amongst your badges."
            errors.push(message) unless errors.include?(message)
          end

        end # Mark badge as due

      end # level > 0
      
    end # each member

    ret_val.merge(success: ret_val[:errors].empty?)
  end

end
