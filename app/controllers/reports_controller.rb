class ReportsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_section_type :youth_section }

  def index
  end

  def due_badges
    require_osm_permission(:read, :badge)
    due_badges = Osm::Badges.get_due_badges(current_user.osm_api, current_section)
    @check_stock = params[:check_stock].eql?('1')
    @by_member = due_badges.by_member
    @badge_totals = due_badges.totals
    @badge_names = due_badges.badge_names
    @member_names = due_badges.member_names
    @badge_stock = @include_stock ? Osm::Badges.get_stock(current_user.osm_api, current_section) : {}
    @by_badge = {}
    @by_member.each do |member_id, badges|
      badges.each do |badge|
        @by_badge[badge] ||= []
        @by_badge[badge].push member_id
      end
    end
  end

  def awarded_badges
    require_osm_permission(:read, :badge)
    skip_activity_badges = (current_section.subscription_level < 2) # Bronze does not include activity badges

    (@start, @finish) = [Osm.parse_date(params[:start]), Osm.parse_date(params[:finish])].sort
    if @start.nil? || @finish.nil?
      flash[:errror] = 'You failed to provide at least one of the dates.'
      redirect_back_or_to reports_path
    end

    if skip_activity_badges
      flash[:information] = 'Activity badges have been excluded since the section does not have a silver subscription in OSM.'
    end

    terms = Osm::Term.get_for_section(current_user.osm_api, current_section)
    terms = terms.select{ |t| !(t.finish < @start) || t.start > @finish }

    @badge_types = []
    @badge_types.push [:core, 'Core']
    @badge_types.push [:challenge, 'Challenge']
    @badge_types.push [:activity, 'Activity'] unless skip_activity_badges
    @badge_types.push [:staged, 'Staged Activity']

    badges = {
      :core => Osm::CoreBadge.get_badges_for_section(current_user.osm_api, current_section),
      :staged => Osm::StagedBadge.get_badges_for_section(current_user.osm_api, current_section),
      :challenge => Osm::ChallengeBadge.get_badges_for_section(current_user.osm_api, current_section),
    }
    unless skip_activity_badges
      badges[:activity] = Osm::ActivityBadge.get_badges_for_section(current_user.osm_api, current_section)
    end

    @badge_names = {}
    badges.each do |type, bs|
      bs.each do |b|
        @badge_names[b.osm_key] = b.name
      end
    end

    @by_badge = { :core => {},  :staged => {},  :challenge => {},  :activity => {} }
    @by_member = {}
    @member_totals = {}
    @badge_totals = { :core => {},  :staged =>{},  :challenge => {},  :activity => {} }

    terms.each do |term|
      # For each term get the summaries and process them
      summaries = {
        :core => Osm::CoreBadge.get_summary_for_section(current_user.osm_api, current_section, term),
        :challenge => Osm::ChallengeBadge.get_summary_for_section(current_user.osm_api, current_section, term),
      }
      unless skip_activity_badges
        summaries[:activity] = Osm::ActivityBadge.get_summary_for_section(current_user.osm_api, current_section, term)
      end
      summaries.each do |type, summary|
        summary.each do |member|
          member.each do |badge_key, value|
            # For each member per summary check awarded date and add details if relevant
            unless @badge_names[badge_key].nil?
              # It's a badge
              if value.match(Osm::OSM_DATE_REGEX)
                # It's been earnt
                date = Osm::parse_date(value)
                if (date >= @start) && (date <= @finish)
                  name = "#{member[:first_name]} #{member[:last_name]}"
                  @by_member[name] ||= { :core => [],  :staged => [],  :challenge => [],  :activity => [] }
                  @by_member[name][type] ||= []
                  unless @by_member[name][type].include?(badge_key)
                    # Not already processed
                    @by_member[name][type].push badge_key
                    @by_badge[type][badge_key] ||= []
                    @by_badge[type][badge_key].push name
                    @member_totals[name] ||= 0
                    @member_totals[name] += 1
                    @badge_totals[type][badge_key] ||= 0
                    @badge_totals[type][badge_key] += 1
                  end
                end # awarded date is in the correct range
              end # value is a date
            end # check it's a badge
          end # each record in a summary
        end
      end # summary in summaries

      staged_badges = Osm::StagedBadge.get_badges_for_section(current_user.osm_api, current_section)
      staged_badges.each do |staged_badge|
        staged_badge.get_data_for_section(current_user.osm_api, current_section).each do |data|
          if data.awarded_date?
            # It has been awarded
            name = "#{data[:first_name]} #{data[:last_name]}"
            badge_key = staged_badge.osm_key
            badge_key_level = "#{badge_key}_#{data.awarded}"
            @badge_names[badge_key_level] ||= "#{staged_badge.name} (Level #{data.awarded})"
            @by_member[name][:staged] ||= []
            unless @by_member[name][:staged].include?(badge_key_level)
              @by_member[name][:staged].push badge_key_level
              @by_badge[:staged][badge_key] ||= []
              @by_badge[:staged][badge_key].push "#{name} (Level #{data.awarded})"
              @member_totals[name] ||= 0
              @member_totals[name] += 1
              @badge_totals[:staged][badge_key] ||= 0
              @badge_totals[:staged][badge_key] += 1
            end
          end
        end # each data row for badge
      end # staged_badge in staged_badges
    end # term in terms
  end

end
