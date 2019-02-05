class BadgeCompletionMatrixReport < LongRunningReport
  class << self
    private
    def cache_key(user_id, section_id, include_core:, include_challenge:, include_staged:, include_activity:, exclude_not_started:, exclude_all_finished:)
      "#{self.name}-a-#{user_id}-#{section_id}-"
      + [include_core, include_challenge, include_staged, include_activity, exclude_not_started, exclude_all_finished]
        .map { |v| v ? 't' : 'f' }.join
    end

    def fetch_data(user_id, section_id, include_core:, include_challenge:, include_staged:, include_activity:, exclude_not_started:, exclude_all_finished:)
      user = User.find(user_id)
      osm_api = user.osm_api
      section = Osm::Section.get(osm_api, section_id)

      matrix = []
      names = []
      member_ids = []

      badges = []
      badges += Osm::CoreBadge.get_badges_for_section(user.osm_api, section) if include_core
      badges += Osm::StagedBadge.get_badges_for_section(user.osm_api, section) if include_staged
      badges += Osm::ChallengeBadge.get_badges_for_section(user.osm_api, section) if include_challenge
      badges += Osm::ActivityBadge.get_badges_for_section(user.osm_api, section) if include_activity
      badges.select!{ |b| !b.add_columns? } # Skip badges we add columns to

      unless badges.first.nil?
        data = badges.first.get_data_for_section(user.osm_api, section)
        names = data.map{ |i| "#{i.first_name} #{i.last_name}" }
        member_ids = data.map{ |i| i.member_id }
      end

      # Exclude any badges matching the criteria
      if exclude_not_started || exclude_all_finished
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
          if exclude_not_started
            # exclude the badge if noone has started it
            exclude ||= started[badge.identifier].eql?(0)
          end
          if exclude_all_finished
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

      {
        names: names,
        matrix: matrix,
      }
    end
  end
end
