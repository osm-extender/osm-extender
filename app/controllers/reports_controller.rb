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
    log_usage
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

    log_usage(
      :sub_action => request.format.to_s,
      :extra_details => {
        :groupings => selected_groupings,
        :events => @my_params['events'].select{ |k,v| v.eql?('1') }.map{ |k,v| k.to_i},
      }
    )
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
        require_osm_permission(:read, :programme, current_user, section.to_i) or return
      end
    end
    @my_params[:events].each do |section, selected|
      if selected.eql?('1')
        require_osm_permission(:read, :events, current_user, section.to_i) or return
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

    log_usage(:sub_action => request.format.to_s, :extra_details => @options, :section_id => nil)
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

    terms = Osm::Term.get_for_section(osm_api, current_section)
    terms.select!{ |t| !(t.finish < @start) || t.start > @finish }

    @badge_types = {
      :core => 'Core',
      :challenge => 'Challenge',
      :staged => 'Staged Activity and Partnership',
    }
    @badge_types[:activity] = 'Activity' unless (current_section.subscription_level < 2) # Bronze does not include activity badges

    @by_badge = { :core => {},  :staged => {},  :challenge => {},  :activity => {} }
    @by_member = {}
    @member_totals = {}
    @badge_names = {}
    @badge_totals = { :core => {},  :staged =>{},  :challenge => {},  :activity => {} }
    badge_clases = { core: Osm::CoreBadge, staged: Osm::StagedBadge, activity: Osm::ActivityBadge, challenge: Osm::ChallengeBadge }

    terms.each do |term|
      # For each term get the badge data and process it
      @badge_types.keys.each do |badge_type|
        badges = badge_clases[badge_type].get_badges_for_section(osm_api, current_section)
        badges.each do |badge|
          @badge_names[badge.identifier] = badge.name
          badge.get_data_for_section(osm_api, current_section, term).each do |data|
            if data.awarded_date? && (data.awarded_date >= @start) && (data.awarded_date <= @finish)
              # It has been awarded
              name = "#{data[:first_name]} #{data[:last_name]}"
              badge_key = badge.identifier
              badge_key_level = badge_type.eql?(:staged) ? "#{badge_key}_#{data.awarded}" : badge_key
              @badge_names[badge_key_level] ||= badge_type.eql?(:staged) ? "#{badge.name} (Level #{data.awarded})" : badge.name
              @by_member[name] ||= { :core => [],  :staged => [],   :challenge => [],  :activity => [] }
              unless @by_member[name][badge_type].include?(badge_key_level)
                @by_member[name][badge_type].push badge_key_level
                @by_badge[badge_type][badge_key] ||= []
                @by_badge[badge_type][badge_key].push badge_type.eql?(:staged) ? "#{name} (Level #{data.awarded})" : name
                @member_totals[name] ||= 0
                @member_totals[name] += 1
                @badge_totals[badge_type][badge_key] ||= 0
                @badge_totals[badge_type][badge_key] += 1
              end
            end # if data.awarded?
          end # each data row for badge
        end # badge in badges
      end # each badge_type
    end # term in terms
    log_usage(:extra_details => {:start => @start, :finish => @finish})
  end


  def badge_completion_matrix
    require_section_type Constants::YOUTH_AND_ADULT_SECTIONS or return
    require_osm_permission(:read, :events) or return

    options = {
      :include_core => @my_params[:include_core].eql?('1'),
      :include_challenge => @my_params[:include_challenge].eql?('1'),
      :include_staged => @my_params[:include_staged].eql?('1'),
      :include_activity => @my_params[:include_activity].eql?('1') && (current_section.subscription_level > 1) # Bronze does not include activity badges
    }
    (@names, @matrix) = Report.badge_completion_matrix(current_user, current_section, options)

    respond_to do |format|
      format.html # html
      format.csv do
        send_sv_file({:col_sep => ',', :headers => ['Badge Type', 'Badge', 'Requirement Group', 'Requirement', *@names]}, 'BadgeCompletionMatrix.csv', 'text/csv') do |csv|
          @matrix.each do |item|
            csv << item
          end
        end
      end # csv
      format.tsv do
        send_sv_file({:col_sep => "\t", :headers => ['Badge Type', 'Badge', 'Requirement Group', 'Requirement', *@names]}, 'BadgeCompletionMatrix.tsv', 'text/tsv') do |csv|
          @matrix.each do |item|
            csv << item
          end
        end
      end # tsv
    end

    log_usage(:sub_action => request.format.to_s, :extra_details => @options)
  end


  def missing_badge_requirements
    require_section_type Constants::YOUTH_SECTIONS or return
    require_osm_permission(:read, :badge) or return

    @badge_data_by_member = {}
    @badge_data_by_badge = {}
    @member_names = {}
    @badge_names = {:core => {}, :staged => {}, :activity => {}, :challenge => {}}
    @badge_requirement_labels = {}

    @badge_types = {}
    @badge_types[:core] = 'Core' if @my_params[:include_core].eql?('1')
    @badge_types[:challenge] = 'Challenge' if @my_params[:include_challenge].eql?('1')
    @badge_types[:staged] = 'Staged Activity and Partnership' if @my_params[:include_staged].eql?('1')
    if @my_params[:include_activity].eql?('1') && (current_section.subscription_level > 1) # Bronze does not include activity badges
      @badge_types[:activity] = 'Activity'
    end

    badges = {}
    badges[:core] = Osm::CoreBadge.get_badges_for_section(osm_api, current_section) if @badge_types.has_key?(:core)
    badges[:staged] = Osm::StagedBadge.get_badges_for_section(osm_api, current_section) if @badge_types.has_key?(:staged)
    badges[:challenge] = Osm::ChallengeBadge.get_badges_for_section(osm_api, current_section) if @badge_types.has_key?(:challenge)
    badges[:activity] = Osm::ActivityBadge.get_badges_for_section(osm_api, current_section) if @badge_types.has_key?(:activity)

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
        badge.get_data_for_section(osm_api, current_section).each do |data|
          if data.started?
            @member_names[data.member_id] = "#{data[:first_name]} #{data[:last_name]}"
            @badge_data_by_member[data.member_id] ||= {}
            @badge_data_by_member[data.member_id][type] ||= []
            if badge.osm_key.eql?('adventure')
              @badge_data_by_member[data.member_id][type].push "Adventure - completed #{data.gained_in_sections['a']} of #{badge.needed_from_section['a']}"
            elsif ['nightsaway', 'hikes', 'timeonthewater'].include?(badge.osm_key)
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

    log_usage
  end


  def planned_badge_requirements
    require_section_type Constants::YOUTH_SECTIONS or return
    require_osm_permission(:read, [:badge, :member, :register]) or return
    if (current_section.subscription_level > 1) # Only for silver and above
      require_osm_permission(:read, :events) or return
    end

    dates = [Osm.parse_date(@my_params[:start]), Osm.parse_date(@my_params[:finish])]
    if dates.include?(nil)
      flash[:errror] = 'You failed to provide at least one of the dates.'
      redirect_back_or_to reports_path
      return
    end
    (@start, @finish) = dates.sort
    @check_stock = @my_params[:check_stock].eql?('1')
    @check_earnt = @my_params[:check_earnt].eql?('1')
    check_event_attendance = @my_params[:check_event_attendance].eql?('1')
    check_meeting_attendance = @my_params[:check_meeting_attendance].eql?('1')
    @badge_stock = @check_stock ? Osm::Badges.get_stock(osm_api, current_section) : {}
    @badge_stock.default = 0

    badge_by_type = {
      'activity' => Osm::ActivityBadge,
      'staged' => Osm::StagedBadge,
      'challenge' => Osm::ChallengeBadge,
      'core' => Osm::CoreBadge,
    }
    badges = {}
    badge_data = {}

    @by_badge = {}
    @by_meeting = {}
    @by_event = {}
    all_requirements = {} # key is an Osm::Meeting or Osm::Event, value is array f hashes of the information
    meeting_attendance = {} # Key is member ID, value is the combined Hash of attendance dates
    event_attendance = {} # Key is member ID, value is a Hash of event ID to attending symbol
    @earnt_badges = {}
    terms = Osm::Term.get_for_section(osm_api, current_section).select{ |term| !(term.finish < @start) && !(term.start > @finish) }


    # For events
    if (current_section.subscription_level > 1) # Only for silver and above
      events = Osm::Event.get_list(osm_api, current_section)
      events.select!{ |e|  (e[:start] >= @start) && (e[:start] <= @finish) }
      events.map!{ |e| Osm::Event.get(osm_api, current_section, e[:id]) }
      events.each do |event|
        # Get badge requirements
        @by_event[event] ||= {} unless event.badges.empty?
        all_requirements[event] ||= []
        event.badges.each do |bl|
          next unless bl.badge_section.eql?(current_section.type)
          badge_name = "#{bl.badge_label} #{bl.badge_type} badge"
          requirement_name = bl.requirement_label
          @by_badge[badge_name] ||= []
          @by_badge[badge_name].push requirement_name unless @by_badge[badge_name].include?(requirement_name)
          @by_event[event][badge_name] ||= []
          @by_event[event][badge_name].push requirement_name unless @by_event[event][badge_name].include?(requirement_name)
          all_requirements[event].push({
              'section' => bl.badge_section.to_s,
              'badgetype' => bl.badge_type.to_s,
              'badge' => bl.badge_key,
              'columnname' => bl.requirement_key,
              'data' => 'YES',
          })
        end # each bl
        # Get attendance
        if check_event_attendance
          terms.each do |term| # Make sure we get people who have left but still attending
            event.get_attendance(osm_api, term).each do |attendance|
              event_attendance[attendance.member_id] ||= {}
              event_attendance[attendance.member_id][event.id] = attendance.attending
            end # each attendance
          end # each term
        end
      end # each event
    end


    # For meetings
    terms.each do |term|
      # Get badge requirements
      Osm::Meeting.get_for_section(osm_api, current_section, term).each do |meeting|
        next if (meeting.date > @finish) || (meeting.date < @start)
        badge_links = meeting.get_badge_requirements(osm_api)
        badge_links.select!{ |l| l['section'] == current_section.type.to_s} # No point reporting badges for a different section
        all_requirements[meeting] ||= [] unless badge_links.empty?
        badge_links.each do |badge_link|
          badge_name = "#{badge_link['badgeName']} #{badge_link['badgetype']} badge"
          requirement_name = badge_link['name']
          @by_meeting[meeting] ||= {}
          @by_meeting[meeting][badge_name] ||= []
          @by_meeting[meeting][badge_name].push requirement_name unless @by_meeting[meeting][badge_name].include?(requirement_name)
          @by_badge[badge_name] ||= []
          @by_badge[badge_name].push requirement_name unless @by_badge[badge_name].include?(requirement_name)
          all_requirements[meeting].push badge_link.merge({'data' => 'YES'})
        end
      end # meetings for section
      # Get attendance
      if check_meeting_attendance
        Osm::Register.get_attendance(osm_api, current_section, term).each do |attendance_data|
          meeting_attendance[attendance_data.member_id] ||= {}
          meeting_attendance[attendance_data.member_id].merge!(attendance_data.attendance)
        end # each attendance_data
      end
    end # terms in date range

    if @check_earnt
      # Fast forward badge requirements
      all_requirements.each do |thing, requirements|
        requirements.each do |requirement|
          unless requirement['badgetype'].eql?('activity') && (current_section.subscription_level < 2) # Silver or higher required for activity badges
            badge_key = "#{requirement['section']}|#{requirement['badgetype']}|#{requirement['badge']}"
            badge = badges[badge_key]
            if badge.nil?
              badge_class = badge_by_type[requirement['badgetype']]
              badge = badge_class.get_badges_for_section(osm_api, current_section).select{ |b| b.osm_key == requirement['badge'] }.first unless badge_class.nil?
              badges[badge_key] = badge
            end
            unless badge.nil?
              badge_data[badge] ||= badge.get_data_for_section(osm_api, current_section)
              badge_data[badge].each do |data|
                do_this_one = false
                if thing.is_a?(Osm::Meeting)
                  do_this_one = !check_meeting_attendance || [nil, :yes].include?(meeting_attendance[data.member_id][thing.date]) # They were present or attendance was not taken (yet)
                elsif thing.is_a?(Osm::Event)
                  do_this_one = !check_event_attendance || [:yes, :invited, :shown, :reserved].include?(event_attendance[data.member_id][thing.id]) # They may be present
                end
                if do_this_one
                  data.requirements[requirement['columnname']] = requirement['data']
                end
              end
            end
          end
        end # each requirement
      end # each thing

      # Get list of finished badges
      badge_data.each do |badge, datas|
        datas.each do |data|
          unless data.awarded?
            if data.earnt?
              member_name = "#{data.first_name} #{data.last_name}"
              key = [badge, data.earnt]
              @earnt_badges[key] ||= []
              @earnt_badges[key].push member_name
            end
          end
        end
      end

      # Get participation badges
      badge = Osm::StagedBadge.get_badges_for_section(osm_api, current_section).select{ |b| b.osm_key == 'participation' }.first
      Osm::Member.get_for_section(osm_api, current_section).each do |member|
        next if member.grouping_id == -2  # Leaders don't get these participation badges
        next_level_due = ((Time.zone.now - member.started.to_time) / 1.year).ceil
        if (@start..@finish).include?(member.started + next_level_due.years)
          key = [badge, next_level_due]
          @earnt_badges[key] ||= []
          @earnt_badges[key].push member.name
        end
      end
    end # if @check_earnt

    log_usage
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

      my_permissions = osm_api.get_user_permissions[section.id]
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

    log_usage
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
