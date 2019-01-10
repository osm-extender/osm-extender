class ReportsController < ApplicationController
  before_action :require_connected_to_osm
  before_action { @my_params = (params[params[:action]] || {}) }


  def index
    @sections = Osm::Section.get_all(osm_api)

    if has_osm_permission?(:read, :member)
      @groupings = get_current_section_groupings.sort do |a,b|
        result = 1 if a[1] == -2
        result = -1 if b[1] == -2
        result = (a[0] <=> b[0]) if result.nil?
        result
      end
    else
      @groupings = []
    end

    if has_osm_permission?(:read, :events)
      @future_events = Osm::Event.get_list(osm_api, current_section).select{ |e| (e[:start].nil? || (e[:start] >= Date.current)) && !e[:archived] }
    end
  end


  def due_badges
    require_section_type Constants::YOUTH_SECTIONS or return
    require_osm_permission(:read, :badge) or return
    due_badges = Osm::Badges.get_due_badges(osm_api, current_section)
    @check_stock = @my_params[:check_stock].eql?('1')
    @by_member = due_badges.by_member
    @badge_totals = due_badges.totals
    @badge_names = due_badges.badge_names
    @member_names = due_badges.member_names
    @badge_stock = due_badges.badge_stock
    @by_badge = {}
    @by_member.each do |member_id, badges|
      badges.each do |badge|
        @by_badge[badge] ||= []
        @by_badge[badge].push member_id
      end
    end
  end


  def event_attendance
    require_section_type Constants::YOUTH_AND_ADULT_SECTIONS or return
    require_osm_permission(:read, :events) or return

    unless @my_params['events'].is_a?(Hash)
      flash[:error] = 'You must select at least one event to get the attendance for.'
      redirect_to reports_path
      return
    end

    unless @my_params['groupings'].is_a?(Hash)
      flash[:error] = "You must select at least one #{get_grouping_name(current_section.type)} to get the attendance for."
      redirect_to reports_path
      return
    end


    selected_groupings = @my_params['groupings'].select{ |k,v| v.eql?('1') }.map{ |k,v| k.to_i}
    @grouping_names = get_current_section_groupings.invert.to_a.select{ |g| selected_groupings.include?(g[0]) }.sort do |a,b|
      result = 1 if a[0] == -2
      result = -1 if b[0] == -2
      result = (a[1] <=> b[1]) if result.nil?
      result
    end

    data = Report.event_attendance(current_user, current_section, @my_params['events'].to_a.select{|i| i[1].eql?('1')}.map{|i| i[0].to_i}, selected_groupings)
    @event_names = data[:event_names]
    @row_groups = data[:row_groups]
    @member_totals = data[:member_totals]
    @event_totals = data[:event_totals]

    respond_to do |format|
      format.html # html
      format.csv do
        send_sv_file({:col_sep => ',', :headers => ['Name', *@event_names]}, 'event_attendance.csv', 'text/csv') do |csv|
          @row_groups.values.each do |group|
            group.each do |row|
              row = row[1]
              csv << ["#{row[0].first_name} #{row[0].last_name}", *row.map{ |i| i.attending}]
            end
          end
        end
      end # csv
      format.tsv do
        send_sv_file({:col_sep => "\t", :headers => ['Name', *@event_names]}, 'event_attendance.tsv', 'text/tsv') do |csv|
          @row_groups.values.each do |group|
            group.each do |row|
              row = row[1]
              csv << ["#{row[0].first_name} #{row[0].last_name}", *row.map{ |i| i.attending}]
            end
          end
        end
      end # tsv
    end
  end


  def calendar
    dates = [Osm.parse_date(@my_params[:start]), Osm.parse_date(@my_params[:finish])]
    if dates.include?(nil)
      flash[:error] = 'You failed to provide at least one of the dates.'
      redirect_back_or_to reports_path
      return
    end
    (@start, @finish) = dates.sort

    unless @my_params[:programme].is_a?(Hash) || @my_params[:events].is_a?(Hash)
      flash[:error] = 'You must select something to show on the calendar'
      redirect_to reports_path
      return
    end
    @my_params[:programme] ||= {}
    @my_params[:events] ||= {}

    @my_params[:programme].each do |section, selected|
      if selected.eql?('1')
        require_osm_permission(:read, :programme, section: section.to_i) or return
      end
    end
    @my_params[:events].each do |section, selected|
      if selected.eql?('1')
        require_osm_permission(:read, :events, section: section.to_i) or return
      end
    end

    @items = Report.calendar(current_user, @my_params.merge(start: @start, finish: @finish))

    respond_to do |format|
      format.html # html
      format.csv do
        send_sv_file({:col_sep => ',', :headers => ['When', 'Section', 'Type', 'What']}, 'calendar.csv', 'text/csv') do |csv|
          @items.each do |item|
            csv << [item.start.strftime(item.start.hour.eql?(0) ? '%Y-%m-%d' : '%Y-%m-%d %H:%M:%S'), get_section_names[item.section_id], 'Event', item.name] if item.is_a?(Osm::Event)
            csv << [item.date.strftime('%Y-%m-%d')+(item.start_time ? " #{item.start_time}:00" : ''), get_section_names[item.section_id], 'Programme', item.title] if item.is_a?(Osm::Meeting)
          end
        end
      end # csv
      format.tsv do
        send_sv_file({:col_sep => "\t", :headers => ['When', 'Section', 'Type', 'What']}, 'calendar.tsv', 'text/tsv') do |csv|
          @items.each do |item|
            csv << [item.start.strftime(item.start.hour.eql?(0) ? '%Y-%m-%d' : '%Y-%m-%d %H:%M:%S'), get_section_names[item.section_id], 'Event', item.name] if item.is_a?(Osm::Event)
            csv << [item.date.strftime('%Y-%m-%d')+(item.start_time ? " #{item.start_time}:00" : ''), get_section_names[item.section_id], 'Programme', item.title] if item.is_a?(Osm::Meeting)
          end
        end
      end # tsv
      format.ics # ICS
    end
  end


  def awarded_badges
    require_section_type Constants::YOUTH_SECTIONS or return
    require_osm_permission(:read, :badge) or return

    dates = [Osm.parse_date(@my_params[:start]), Osm.parse_date(@my_params[:finish])]
    if dates.include?(nil)
      flash[:errror] = 'You failed to provide at least one of the dates.'
      redirect_back_or_to reports_path
      return
    end
    (@start, @finish) = dates.sort

    badge_clases = { core: Osm::CoreBadge, staged: Osm::StagedBadge, activity: Osm::ActivityBadge, challenge: Osm::ChallengeBadge }
    @badge_types = {
      :core => 'Core',
      :challenge => 'Challenge',
      :staged => 'Staged Activity and Partnership',
    }
    @badge_types[:activity] = 'Activity' if current_section.subscription_at_least?(:silver) # Bronze does not include activity badges

    @badges = {}
    @badge_types.keys.each do |badge_type|
      badge_clases[badge_type].get_badges_for_section(osm_api, current_section).each do |badge|
        @badges[badge.identifier] = badge
      end
    end

    @by_badge = { :core => {},  :staged => {},  :challenge => {},  :activity => {} }
    @by_member = {}
    @member_totals = {}
    @badge_totals = { :core => {},  :staged =>{},  :challenge => {},  :activity => {} }
    members_seen = [] # IDs of members we've already processed, allows skipping of terms (saving API use) if we won't get more information by quering for it's badge data

    terms = Osm::Term.get_for_section(osm_api, current_section).sort
    terms.select!{ |t| !((t.finish < @start) || (t.start > @finish)) }
    terms = [terms[-1], *terms[0..-2]] # Check last, first then other terms - more chance of getting all members in least API traffic
    terms.each do |term|
      # Get summaries to check which badges we're interested in
      summary = Osm::Badge.get_summary_for_section(osm_api, current_section, term)

      # Skip term if we've already seen all the members we just got data for
      next term unless summary.map{ |i| members_seen.include?(i[:member_id]) }.include?(false)

      # Process data from the summary
      badge_data = {} # Cache variable badge.identifier to data
      summary.each do |s|
        this_name = s[:name]
        this_member_id = s[:member_id]
        next s if members_seen.include?(this_member_id) # No point processing this member again
        s.each do |k,v|
          next k if k.is_a?(Symbol)
          this_badge = this_date = this_level = nil
          if v.eql?(:awarded)
            # Found a badge which has been awarded
            this_badge = @badges[k]
            next k if this_badge.nil? # SHouldn't happen but we'll play if safe by checking
            unless s["#{k}_date"].nil?
              # The summary gave us the date too, lucky us
              if !this_badge.has_levels? || !s["#{k}_level"].nil?
                # The summary also gave us the level (or the badge doesn't have levels)
                this_date = s["#{k}_date"]
                this_level = s["#{k}_level"] if this_badge.has_levels?
              end
            end
            if this_date.nil?
              # The summary didn't give us the date (or level), time to get it the long way
              badge_data[k] ||= this_badge.get_data_for_section(osm_api, current_section, term) # no point getting it if we already had to
              this_data = badge_data[k].find{ |d| d.member_id.eql?(this_member_id) }
              next s if this_data.nil? # Shouldn't happen but if it does we can't go any further
              this_date = this_data.awarded_date
              this_level = this_data.awarded if this_badge.has_levels?
            end # was date in the summary
            # Add this data to the lists
            if (this_date >= @start) && (this_date <= @finish)
              @by_member[this_name] ||= { :core => [],  :staged => [],   :challenge => [],  :activity => [] }
              @by_member[this_name][this_badge.type].push([this_badge.identifier, this_level])
              @by_badge[this_badge.type][this_badge.identifier] ||= {}
              @by_badge[this_badge.type][this_badge.identifier][this_level] ||= []
              @by_badge[this_badge.type][this_badge.identifier][this_level].push(this_name)
              @member_totals[this_name] ||= 0
              @member_totals[this_name] += 1
              @badge_totals[this_badge.type][this_badge.identifier] ||= 0
              @badge_totals[this_badge.type][this_badge.identifier] += 1
            end
          end # item is one which has been awarded
          members_seen.push this_member_id # Add this member to the list of ones we've seen
        end # each item in the summary
      end # each summary
    end # each term


    #  # Get data for interesting badges
    #  @badge_types.keys.each do |badge_type|
    #    badges = @badges[badge_type].select{ |b| badges_to_get.include?(b.identifier) }
    #    badges.each do |badge|
    #      @badge_names[badge.identifier] = badge.name
    #      badge_data = badge.get_data_for_section(osm_api, current_section, term)
    #      badge_data.each do |data|
    #        if data.awarded_date? && (data.awarded_date >= @start) && (data.awarded_date <= @finish)
    #          # It has been awarded
    #          name = "#{data[:first_name]} #{data[:last_name]}"
    #          badge_key = badge.identifier
    #          badge_key_level = badge_type.eql?(:staged) ? "#{badge_key}_#{data.awarded}" : badge_key
    #          @badge_names[badge_key_level] ||= badge_type.eql?(:staged) ? "#{badge.name} (Level #{data.awarded})" : badge.name
    #          @by_member[name] ||= { :core => [],  :staged => [],   :challenge => [],  :activity => [] }
    #          unless @by_member[name][badge_type].include?(badge_key_level)
    #            @by_member[name][badge_type].push badge_key_level
    #            @by_badge[badge_type][badge_key] ||= []
    #            @by_badge[badge_type][badge_key].push badge_type.eql?(:staged) ? "#{name} (Level #{data.awarded})" : name
    #            @member_totals[name] ||= 0
    #            @member_totals[name] += 1
    #            @badge_totals[badge_type][badge_key] ||= 0
    #            @badge_totals[badge_type][badge_key] += 1
    #          end
    #        end # if data.awarded?
    #      end # each data row for badge
    #    end # badge in badges
    #  end # each badge_type
    #end # term in terms
  end


  def badge_completion_matrix
    require_section_type Constants::YOUTH_AND_ADULT_SECTIONS or return
    require_osm_permission(:read, :badge) or return

    if params[:waiting]
      if BadgeCompletionMatrixReport.data_for?(
        current_user.id,
        current_section.id,
        include_core: @my_params[:include_core].eql?('1'),
        include_challenge: @my_params[:include_challenge].eql?('1'),
        include_staged: @my_params[:include_staged].eql?('1'),
        include_activity: @my_params[:include_activity].eql?('1') && current_section.subscription_at_least?(:silver), # Bronze does not include activity badges
        exclude_not_started: @my_params[:hide_not_started].eql?('1'),
        exclude_all_finished: @my_params[:hide_all_finished].eql?('1'),
      )
        @data = BadgeCompletionMatrixReport.data_for(
          current_user.id,
          current_section.id,
          include_core: @my_params[:include_core].eql?('1'),
          include_challenge: @my_params[:include_challenge].eql?('1'),
          include_staged: @my_params[:include_staged].eql?('1'),
          include_activity: @my_params[:include_activity].eql?('1') && current_section.subscription_at_least?(:silver), # Bronze does not include activity badges
          exclude_not_started: @my_params[:hide_not_started].eql?('1'),
          exclude_all_finished: @my_params[:hide_all_finished].eql?('1'),
        )

        respond_to do |format|
          format.html # html
          format.csv do
            send_sv_file({:col_sep => ',', :headers => ['Badge Type', 'Badge', 'Requirement Group', 'Requirement', *@data[:names]]}, 'BadgeCompletionMatrix.csv', 'text/csv') do |csv|
              @data[:matrix].each do |item|
                csv << item
              end
            end
          end # csv
          format.tsv do
            send_sv_file({:col_sep => "\t", :headers => ['Badge Type', 'Badge', 'Requirement Group', 'Requirement', *@data[:names]]}, 'BadgeCompletionMatrix.tsv', 'text/tsv') do |csv|
              @data[:matrix].each do |item|
                csv << item
              end
            end
          end # tsv
        end # respond_to    
      else
        render :waiting
      end
    else
      # Add job
      MissingBadgeRequirementsReport.delay.data_for(
        current_user.id,
        current_section.id,
        include_core: @my_params[:include_core].eql?('1'),
        include_challenge: @my_params[:include_challenge].eql?('1'),
        include_staged: @my_params[:include_staged].eql?('1'),
        include_activity: @my_params[:include_activity].eql?('1') && current_section.subscription_at_least?(:silver), # Bronze does not include activity badges
        exclude_not_started: @my_params[:hide_not_started].eql?('1'),
        exclude_all_finished: @my_params[:hide_all_finished].eql?('1'),
      )
      redirect_to action: :badge_completion_matrix, waiting: '1', missing_badge_requirements: @my_params.symbolize_keys
    end
  end


  def badge_stock_check
    require_section_type Constants::YOUTH_AND_ADULT_SECTIONS or return
    require_osm_permission(:read, :events) or return

    options = {
      :include_core => @my_params[:include_core].eql?('1'),
      :include_challenge => @my_params[:include_challenge].eql?('1'),
      :include_staged => @my_params[:include_staged].eql?('1'),
      :include_activity => @my_params[:include_activity].eql?('1') && current_section.subscription_at_least?(:silver), # Bronze does not include activity badges
      :hide_no_stock => @my_params[:hide_no_stock].eql?('1'),
    }

    @data = Report.badge_stock_check(current_user, current_section, options)

    respond_to do |format|
      format.html # html
      format.csv do
        send_sv_file({:col_sep => ',', :headers => ['Badge Type', 'Group Name', 'Badge', 'Level', 'Stock']}, 'BadgeStock.csv', 'text/csv') do |csv|
          @data.each do |item|
            csv << item
          end
        end
      end # csv
      format.tsv do
        send_sv_file({:col_sep => "\t", :headers => ['Badge Type', 'Group Name', 'Badge', 'Level', 'Stock']}, 'BadgeStock.tsv', 'text/tsv') do |csv|
          @data.each do |item|
            csv << item
          end
        end
      end # tsv
    end
  end


  def missing_badge_requirements
    require_section_type Constants::YOUTH_SECTIONS or return
    require_osm_permission(:read, :badge) or return

    if params[:waiting]
      if MissingBadgeRequirementsReport.data_for?(
        current_user.id,
        current_section.id,
        include_core: @my_params[:include_core].eql?('1'),
        include_challenge: @my_params[:include_challenge].eql?('1'),
        include_activity: @my_params[:include_activity].eql?('1'),
        include_staged: @my_params[:include_staged].eql?('1'),
      )
        @data = MissingBadgeRequirementsReport.data_for(
          current_user.id,
          current_section.id,
          include_core: @my_params[:include_core].eql?('1'),
          include_challenge: @my_params[:include_challenge].eql?('1'),
          include_activity: @my_params[:include_activity].eql?('1'),
          include_staged: @my_params[:include_staged].eql?('1'),
        )
      else
        render :waiting
      end
    else
      # Add job
      MissingBadgeRequirementsReport.delay.data_for(
        current_user.id,
        current_section.id,
        include_core: @my_params[:include_core].eql?('1'),
        include_challenge: @my_params[:include_challenge].eql?('1'),
        include_activity: @my_params[:include_activity].eql?('1'),
        include_staged: @my_params[:include_staged].eql?('1'),
      )
      redirect_to action: :missing_badge_requirements, waiting: '1', missing_badge_requirements: @my_params.symbolize_keys
    end
  end


  def planned_badge_requirements
    require_section_type Constants::YOUTH_SECTIONS or return
    require_osm_permission(:read, :programme) or return
    require_osm_permission(:read, :events) or return if current_section.subscription_at_least?(:silver)

    # Check OSM access for optional stuff
    if @my_params[:check_earnt]
      require_osm_permission(:read, :badge) or return
    end
    if @my_params[:check_event_attendance]
      require_section_subscription(:silver) or return
    end
    if @my_params[:check_meeting_attendance]
      require_osm_permission(:read, :register) or return
    end
    if @my_params[:check_participation] || @my_params[:check_birthday]
      require_osm_permission(:read, :member) or return
    end

    dates = [Osm.parse_date(@my_params[:start]), Osm.parse_date(@my_params[:finish])].sort
    if dates.include?(nil)
      flash[:errror] = 'You failed to provide at least one of the dates.'
      redirect_back_or_to reports_path
      return
    end

    if params[:waiting]
      if PlannedBadgeRequirementsReport.data_for?(
        current_user.id,
        current_section.id,
        start: dates.first,
        finish: dates.last,
        check_earnt: @my_params[:check_earnt].eql?('1'),
        check_stock: @my_params[:check_stock].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_participation: @my_params[:check_participation].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_birthday: @my_params[:check_birthday].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_event_attendance: @my_params[:check_event_attendance].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_meeting_attendance: @my_params[:check_meeting_attendance].eql?('1') && @my_params[:check_earnt].eql?('1')
      )
        @data = PlannedBadgeRequirementsReport.data_for(
          current_user.id,
          current_section.id,
          start: dates.first,
          finish: dates.last,
          check_earnt: @my_params[:check_earnt].eql?('1'),
          check_stock: @my_params[:check_stock].eql?('1') && @my_params[:check_earnt].eql?('1'),
          check_participation: @my_params[:check_participation].eql?('1') && @my_params[:check_earnt].eql?('1'),
          check_birthday: @my_params[:check_birthday].eql?('1') && @my_params[:check_earnt].eql?('1'),
          check_event_attendance: @my_params[:check_event_attendance].eql?('1') && @my_params[:check_earnt].eql?('1'),
          check_meeting_attendance: @my_params[:check_meeting_attendance].eql?('1') && @my_params[:check_earnt].eql?('1')
        )
      else
        render :waiting
      end
    else
      # Add job
      PlannedBadgeRequirementsReport.delay.data_for(
        current_user.id,
        current_section.id,
        start: dates.first,
        finish: dates.last,
        check_earnt: @my_params[:check_earnt].eql?('1'),
        check_stock: @my_params[:check_stock].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_participation: @my_params[:check_participation].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_birthday: @my_params[:check_birthday].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_event_attendance: @my_params[:check_event_attendance].eql?('1') && @my_params[:check_earnt].eql?('1'),
        check_meeting_attendance: @my_params[:check_meeting_attendance].eql?('1') && @my_params[:check_earnt].eql?('1')
      )
      redirect_to action: :planned_badge_requirements, waiting: '1', planned_badge_requirements: @my_params.symbolize_keys
    end
  end

  def leader_access_audit
    unless @my_params[:sections].is_a?(Hash)
      flash[:error] = 'You must select some sections to sudit'
      redirect_to reports_path
      return
    end

    permission_names = {
      10 => 'Read',
      20 => 'Read &amp; Write'.html_safe,
      100 => 'Administer',
      'r' => 'Read',
      'rw' => 'Read &amp; Write'.html_safe,
      'arw' => 'Administer'
    }

    sections = Osm::Section.get_all(osm_api)
    sections.select! { |s| @my_params[:sections][s.id.to_s].eql?('1') }

    @by_section = {}
    @by_leader = {current_user.osm_userid => {}}
    @leader_names = {current_user.osm_userid => "#{current_user.name} (YOU)"}
    @section_names = {}

    sections.each do |section|
      @by_section[section.id] ||= {}
      @section_names[section.id] = "#{section.name} (#{section.group_name})"

      my_permissions = osm_api.get_user_permissions[section.id] || {}
      my_permissions = Hash[my_permissions.map{ |k,v| [k.to_s, permission_names[v.map{ |i| i.to_s.first }.sort.join]] }]
      @by_section[section.id][current_user.osm_userid] = my_permissions
      @by_leader[current_user.osm_userid][section.id] = my_permissions

      leaders = osm_api.perform_query("ext/settings/access/?action=getUsersForSection&sectionid=#{section.id}")
      leaders.each do |leader|
        leader_id = leader['userid'].to_i
        @by_leader[leader_id] ||= {}
        @leader_names[leader_id] = leader['firstname']
        permissions = Hash[leader['permissions'].map{ |k,v| [k, permission_names[v.to_i]] }]
        @by_section[section.id][leader_id] = permissions
        @by_leader[leader_id][section.id] = permissions
      end
    end
  end


  def members_photos
    require_osm_permission(:read, :member) or return
    members = Osm::Member.get_for_section(current_user.osm_api, current_section).group_by{ |i| i.grouping_id }
    grouping_names = Osm::Grouping.get_for_section(current_user.osm_api, current_section).map{ |i| [i.id, i.name] }.to_h
    grouping_names.default = 'Members not in a grouping'

    # Create members_by_grouping - a hash of grouping name to array of members
    @members_by_grouping = {}
    members.keys.sort.each do |grouping_id|
      @members_by_grouping[grouping_names[grouping_id]] = members[grouping_id]
    end
  end

  private
  def send_sv_file(options={}, file_name, mime_type, &generate_data)
    options.reverse_merge!({
      :col_sep => ',',
      :write_headers => !!options[:headers],
      :force_quotes => true,
      :quote_char => '"',
      :skip_blanks => true,
    })
    csv_string = CSV.generate(options, &generate_data)
    send_data csv_string, :filename => file_name, :type => mime_type, :disposition => 'attachment'
  end

end
