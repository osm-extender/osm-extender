class ReportsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter ({:only => [:due_badges, :awarded_badges, :missing_badge_requirements]}) { require_section_type Constants::YOUTH_SECTIONS }
  before_filter ({:only => [:calendar]}) { require_section_type Constants::YOUTH_AND_ADULT_SECTIONS }


  def index
    @sections = Osm::Section.get_all(current_user.osm_api)
  end


  def due_badges
    require_osm_permission(:read, :badge)
    due_badges = Osm::Badges.get_due_badges(current_user.osm_api, current_section)
    @check_stock = params[:check_stock].eql?('1')
    @by_member = due_badges.by_member
    @badge_totals = due_badges.totals
    @badge_names = due_badges.badge_names
    @member_names = due_badges.member_names
    @badge_stock = @check_stock ? Osm::Badges.get_stock(current_user.osm_api, current_section) : {}
    @by_badge = {}
    @by_member.each do |member_id, badges|
      badges.each do |badge|
        @by_badge[badge] ||= []
        @by_badge[badge].push member_id
      end
    end
  end


  def calendar
    require_osm_permission(:read, [:events, :programme])
    (@start, @finish) = [Osm.parse_date(params[:calendar_start]), Osm.parse_date(params[:calendar_finish])].sort
    @items = []
    Osm::Section.get_all(current_user.osm_api).select{ |s| s.youth_section? || s.adults? }.each do |section|
      if params['events'][section.id.to_s].eql?('1')
        Osm::Event.get_for_section(current_user.osm_api, section).each do |event|
          unless event.start.nil?
            event_date = event.finish.nil? ? event.start : event.finish
            unless (event_date < @start) || (event_date > @finish)
              @items.push [event_date, event]
            end
          end
        end
      end

      if params['programme'][section.id.to_s].eql?('1')
        Osm::Term.get_for_section(current_user.osm_api, section).each do |term|
          unless term.before?(@start) || term.after?(@finish)
            Osm::Meeting.get_for_section(current_user.osm_api, section, term).each do |meeting|
              unless (meeting.date < @start) || (meeting.date > @finish)
                @items.push [meeting.date, meeting]
              end
            end
          end
        end
      end
    end
    
    @items.sort!{ |i1, i2| i1 <=> i2 }
    @items.map!{ |i| i[1]}
  end


  def awarded_badges
    require_osm_permission(:read, :badge)

    (@start, @finish) = [Osm.parse_date(params[:start]), Osm.parse_date(params[:finish])].sort
    if @start.nil? || @finish.nil?
      flash[:errror] = 'You failed to provide at least one of the dates.'
      redirect_back_or_to reports_path
    end

    terms = Osm::Term.get_for_section(current_user.osm_api, current_section)
    terms = terms.select{ |t| !(t.finish < @start) || t.start > @finish }

    @badge_types = {
      :core => 'Core',
      :challenge => 'Challenge',
      :staged => 'Staged Activity and Partnership',
    }
    @badge_types[:activity] = 'Activity' unless (current_section.subscription_level < 2) # Bronze does not include activity badges

    badges = {}
    badges[:core] = Osm::CoreBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:core)
    badges[:staged] = Osm::StagedBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:staged)
    badges[:challenge] = Osm::ChallengeBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:challenge)
    badges[:activity] = Osm::ActivityBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:activity)

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
      summaries = {}
      summaries[:core] = Osm::CoreBadge.get_summary_for_section(current_user.osm_api, current_section, term) if @badge_types.keys.include?(:core)
      summaries[:challenge] = Osm::ChallengeBadge.get_summary_for_section(current_user.osm_api, current_section, term) if @badge_types.keys.include?(:challenge)
      summaries[:activity] = Osm::ActivityBadge.get_summary_for_section(current_user.osm_api, current_section, term) if @badge_types.keys.include?(:activity)
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

      if @badge_types.keys.include?(:staged)
        staged_badges = Osm::StagedBadge.get_badges_for_section(current_user.osm_api, current_section)
        staged_badges.each do |staged_badge|
          staged_badge.get_data_for_section(current_user.osm_api, current_section).each do |data|
            if data.awarded_date?
              # It has been awarded
              name = "#{data[:first_name]} #{data[:last_name]}"
              badge_key = staged_badge.osm_key
              badge_key_level = "#{badge_key}_#{data.awarded}"
              @badge_names[badge_key_level] ||= "#{staged_badge.name} (Level #{data.awarded})"
              @by_member[name] ||= { :core => [],  :staged => [],   :challenge => [],  :activity => [] }
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
      end # doing staged badges
    end # term in terms
  end


  def missing_badge_requirements
    require_osm_permission(:read, :badge)

    @badge_data_by_member = {}
    @badge_data_by_badge = {}
    @member_names = {}
    @badge_names = {:core => {}, :staged => {}, :activity => {}, :challenge => {}}
    @badge_requirement_labels = {}

    @badge_types = {}
    @badge_types[:core] = 'Core' if params[:include_core].eql?('1')
    @badge_types[:challenge] = 'Challenge' if params[:include_challenge].eql?('1')
    @badge_types[:staged] = 'Staged Activity and Partnership' if params[:include_staged].eql?('1')
    if params[:include_activity].eql?('1') && (current_section.subscription_level > 1) # Bronze does not include activity badges
      @badge_types[:activity] = 'Activity'
    end

    badges = {}
    badges[:core] = Osm::CoreBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:core)
    badges[:staged] = Osm::StagedBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:staged)
    badges[:challenge] = Osm::ChallengeBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:challenge)
    badges[:activity] = Osm::ActivityBadge.get_badges_for_section(current_user.osm_api, current_section) if @badge_types.keys.include?(:activity)

    badge_data = {}
    badges.each do |type, bs|
      badge_data[type] = []
      @badge_requirement_labels[type] = {}
      @badge_data_by_badge[type] = {}
      bs.each do |badge|
        @badge_requirement_labels[type][badge.osm_key] = {}
        @badge_names[type][badge.osm_key] = badge.name
        badge.requirements.each do |requirement|
          @badge_requirement_labels[type][badge.osm_key][requirement.field] = requirement.name
        end
        badge.get_data_for_section(current_user.osm_api, current_section).each do |data|
          if data.started?
            @member_names[data.member_id] = "#{data[:first_name]} #{data[:last_name]}"
            @badge_data_by_member[data.member_id] ||= {}
            @badge_data_by_member[data.member_id][type] ||= []
            if badge.osm_key.eql?('adventure')
              @badge_data_by_member[data.member_id][type].push "Adventure - completed #{data.gained_in_sections['a']} of #{badge.needed_from_section['a']}"
            elsif ['nightsaway', 'hikes'].include?(badge.osm_key)
              @badge_data_by_member[data.member_id][type].push "#{badge.name} - completed #{data.requirements['y_01']} of #{data.started}"
            else
              badge_key = badge.type.eql?(:staged) ? "#{badge.osm_key}_#{data.started}" : badge.osm_key
              @badge_data_by_badge[type][badge_key] ||= {}
              @badge_data_by_member[data.member_id][type].push data
              if badge.type.eql?(:staged)
                # Get requirements for only the started level
                requirements = badge.requirements.select{ |r| r.field[0].eql?("abcde"[data.started-1])}
              else
                requirements = badge.requirements
              end
              requirements.each do |requirement|
                value = data.requirements[requirement.field]
                not_met = true
                if requirement.field[0].eql?('y')
                  # It's a count column
                  not_met = (value < 3) if badge.osm_key.eql?('adventure')
                  not_met = (value < 6) if badge.osm_key.eql?('community')
                else
                  not_met = value.blank? || value[0].to_s.downcase.eql?('x')
                end
                if not_met
                  @badge_data_by_badge[type][badge_key][requirement.field] ||= []
                  @badge_data_by_badge[type][badge_key][requirement.field].push data.member_id
                end
              end
            end
          end
        end
      end
    end

    # Suffix levels to names for staged badges
    # (Shallow) copy badge requirement labels for staged badges
    new_badge_names = {}
    @badge_names[:staged].each do |key, label|
      (1..5).each do |level|
        new_badge_names["#{key}_#{level}"] = "#{label} (Level #{level})"
        @badge_requirement_labels[:staged]["#{key}_#{level}"] = @badge_requirement_labels[:staged][key]
      end
    end
    @badge_names[:staged].merge!(new_badge_names)

  end

end
