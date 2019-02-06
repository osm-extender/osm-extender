class MissingBadgeRequirementsReport < LongRunningReport
  class << self
    private
    def cache_key(user_id, section_id, include_core:, include_activity:, include_challenge:, include_staged:)
      "#{self.name}-a-#{user_id}-#{section_id}-"
      + [include_core, include_activity, include_challenge, include_staged]
        .map { |v| v ? 't' : 'f' }.join
    end

    def fetch_data(user_id, section_id, include_core:, include_activity:, include_challenge:, include_staged:)
      user = User.find(user_id)
      osm_api = user.osm_api
      section = Osm::Section.get(osm_api, section_id)

      badge_data_by_member = {}
      badge_data_by_badge = {}
      member_names = {}
      badge_names = {:core => {}, :staged => {}, :activity => {}, :challenge => {}} #TODO flatten
      badge_requirement_labels = {}

      badge_types = {}
      badge_types[:core] = 'Core' if include_core
      badge_types[:challenge] = 'Challenge' if include_challenge
      badge_types[:staged] = 'Staged Activity and Partnership' if include_staged
      if include_activity && section.subscription_at_least?(:silver) # Bronze does not include activity badges
        badge_types[:activity] = 'Activity'
      end

      badges = {}
      badges[:core] = Osm::CoreBadge.get_badges_for_section(osm_api, section) if badge_types.has_key?(:core)
      badges[:staged] = Osm::StagedBadge.get_badges_for_section(osm_api, section) if badge_types.has_key?(:staged)
      badges[:challenge] = Osm::ChallengeBadge.get_badges_for_section(osm_api, section) if badge_types.has_key?(:challenge)
      badges[:activity] = Osm::ActivityBadge.get_badges_for_section(osm_api, section) if badge_types.has_key?(:activity)

      badge_data = {}
      badges.each do |type, bs|
        badge_data[type] = []
        badge_data_by_badge[type] = {}
        badge_requirement_labels[type] ||= {}
        bs.each do |badge|
          badge_names[type][badge.identifier] = badge.name
          badge.get_data_for_section(osm_api, section).each do |data|
            next if badge.add_columns?
            if data.started?
              member_names[data.member_id] = "#{data[:first_name]} #{data[:last_name]}"
              badge_data_by_member[data.member_id] ||= {}
              badge_data_by_member[data.member_id][type] ||= []
              badge_key = badge.type.eql?(:staged) ? "#{badge.identifier}_#{data.started}" : badge.identifier
              badge_requirement_labels[type][badge_key] ||= {}
              badge_data_by_badge[type][badge_key] ||= {}
              badge_data_by_member[data.member_id][type].push data
              if badge.has_levels?
                # Get requirements for only the started level
                requirements = badge.requirements.select{ |r| r.mod.letter.eql?(('a'..'z').to_a[data.started-1])}
              else
                requirements = badge.requirements
              end
              requirements.each do |requirement|
                unless data.requirement_met?(requirement.id)
                  badge_data_by_badge[type][badge_key][requirement.id] ||= []
                  badge_data_by_badge[type][badge_key][requirement.id].push data.member_id
                  badge_requirement_labels[type][badge_key][requirement.id] = requirement.name
                end
              end
            end
          end
        end
      end

      # Suffix levels to names for staged badges
      new_badge_names = {}
      badge_names[:staged].each do |key, label|
        (1..5).each do |level|
          new_badge_names["#{key}_#{level}"] = "#{label} (Level #{level})"
        end
      end
      badge_names[:staged].merge!(new_badge_names)

      {
        badge_types: badge_types,
        badge_names: badge_names,
        badge_requirement_labels: badge_requirement_labels,
        member_names: member_names,
        badge_data_by_badge: badge_data_by_badge,
        badge_data_by_member: badge_data_by_member,
      }
    end
  end
end
