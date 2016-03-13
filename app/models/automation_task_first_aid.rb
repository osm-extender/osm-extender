class AutomationTaskFirstAid < AutomationTask

  ALLOWED_SECTIONS = [:beavers, :cubs]

  REQUIREMENTS_NEEDED = {
    beavers: [115860],
    cubs: [115865, 115866, 20995, 115862, 115863]
  }

  EMERGENCY_AID_BADGE_LEVEL = {
    beavers: 1,
    cubs: 2
  }

  EMERGENCY_AID_BADGE_ID = 1643

  CHALLENGE_BADGE_IDS = {
    beavers: 1515,
    cubs: 1581,
  }

  CHALLENGE_REQUIREMENT_ID = {
    beavers: 20989,
    cubs: 100384
  }

  MET_VALUE = '[YES]'
  NOT_MET_VALUE = ''


  def self.required_permissions
    [ [:write, :badge] ]
  end

  def self.configuration_labels
    {
      overwrite: 'Overwrite existing data?'
    }
  end

  def self.default_configuration
    {
      overwrite: false
    }
  end

  def self.configuration_types
    {
      overwrite: :boolean
    }
  end

  def self.human_name
    "First aid in badges"
  end

  def human_configuration
    "Update first aid coloumn of outdoors challenge badge to \"#{MET_VALUE}\" #{configuration[:overwrite] ? 'overwriting' : 'preserving'} existing data."
  end



  private
  def perform_task(user=self.user)
    ret_val = {log_lines: log_lines=[], errors: errors=[]}

    section = Osm::Section.get(user.osm_api, section_id)
    if section.nil?
      return {success: false, errors: ['Could not retrieve section from OSM.']}
    end

    emergency_aid_badge = Osm::StagedBadge.get_badges_for_section(user.osm_api, section) || []
    emergency_aid_badge = emergency_aid_badge.select{ |b| b.id.eql?(EMERGENCY_AID_BADGE_ID) }.first
    if emergency_aid_badge.nil?
      return {success: false, errors: ["Could not retrieve Emergency Aid badge from OSM."]}
    end

    outdoors_challenge_badge = Osm::ChallengeBadge.get_badges_for_section(user.osm_api, section) || []
    outdoors_challenge_badge = outdoors_challenge_badge.select{ |b| b.id.eql?(CHALLENGE_BADGE_IDS[section.type]) }.first
    if outdoors_challenge_badge.nil?
      return {success: false, errors: ["Could not retrieve Outdoors Challenge badge from OSM."]}
    end

    emergency_aid_badge_data = emergency_aid_badge.get_data_for_section(user.osm_api, section)
    outdoors_challenge_badge_data = Hash[ outdoors_challenge_badge.get_data_for_section(user.osm_api, section).map{ |d| [d.member_id, d] } ]


    emergency_aid_badge_data.each do |ea_data|
      member_name = "#{ea_data.first_name} #{ea_data.last_name}"
      log_lines.push "#{member_name}:"
      log_lines.push(member_lines= [] )

      oc_data = outdoors_challenge_badge_data[ea_data.member_id]
      unless oc_data.nil?
        met = false
        awarded = ( ea_data.awarded >= EMERGENCY_AID_BADGE_LEVEL[section.type] )
        if awarded
          member_lines.push "Awarded level #{ea_data.awarded} on #{ea_data.awarded_date}."
          met = true
        else
          requirements_needed = REQUIREMENTS_NEEDED[section.type].map{ |r| ea_data.requirement_met?(r) }
          member_lines.push "Completed #{requirements_needed.count{ |i| i.eql?(true) }} of #{requirements_needed.count} #{requirements_needed.count > 1 ? 'requirements' : 'requirement'}."
          met = requirements_needed.all?
        end

        current_data = oc_data.requirements[CHALLENGE_REQUIREMENT_ID[section.type]] || ''
        new_data = met ? MET_VALUE : NOT_MET_VALUE

        if configuration[:overwrite]  ||  ( current_data.blank? || current_data.eql?(MET_VALUE) || current_data.eql?(NOT_MET_VALUE) )
          # either we've chosen to overwrite data  or  existing data is blank or one of our values

          unless current_data.eql?(new_data)
            oc_data.requirements[CHALLENGE_REQUIREMENT_ID[section.type]] = new_data
            if oc_data.update(user.osm_api)
              member_lines.push "Updated challenge badge."
            else
              member_lines.push "Couldn't update challenge badge."
              errors.push "Couldn't update challenge badge for #{member_name}"
            end
          else
            # member_lines.push "Didn't update challenge badge as existing data is what would have been set."
          end # new and current are different

        else
          member_lines.push "Didn't update challenge badge as data existed."
        end

      end # oc_data was something
    end # each data in emergency_aid_badge_data


    ret_val.merge(success: ret_val[:errors].empty?)
  end

end
