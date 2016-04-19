class AutomationTaskBirthdayBadge < AutomationTask

  ALLOWED_SECTIONS = [:beavers, :cubs]

  BIRTHDAYS_FOR_SECTION = {
    beavers: [6, 7, 8],
    cubs: [8, 9, 10]
  }


  def self.required_permissions
    [ [:read, :member], [:write, :badge] ]
  end

  def self.configuration_labels
    {
      the_last_n_days: 'How many days into the past?',
      the_next_n_days: 'How many days into the future?',
      badge_6: 'ID of badge for 6th birthday.',
      badge_7: 'ID of badge for 7th birthday.',
      badge_8: 'ID of badge for 8th birthday.',
      badge_9: 'ID of badge for 9th birthday.',
      badge_10: 'ID of badge for 10th birthday.',
    }
  end

  def self.default_configuration
    {
      the_next_n_days: 3,
      the_last_n_days: 2,
      badge_6: -1,
      badge_7: -1,
      badge_8: -1,
      badge_9: -1,
      badge_10: -1,
    }
  end

  def self.configuration_types
    {
      the_next_n_days: :positive_integer,
      the_last_n_days: :positive_integer,
      badge_6: :integer,
      badge_7: :integer,
      badge_8: :integer,
      badge_9: :integer,
      badge_10: :integer,
    }
  end

  def self.human_name
    'Birthday badges'
  end

  def human_configuration
    "Between #{configuration[:the_last_n_days]} #{"day".pluralize(configuration[:the_last_n_days])} ago and #{configuration[:the_next_n_days]} #{"day".pluralize(configuration[:the_next_n_days])} from now."
  end



  private
  def perform_task(user=self.user)
    ret_val = {log_lines: [], errors: []}
    earliest = configuration[:the_last_n_days].days.ago.to_date
    latest = configuration[:the_next_n_days].days.from_now.to_date
    birthdays = []

    ret_val[:log_lines].push 'Checking members'
    ret_val[:log_lines].push (member_lines = [])
    Osm::Member.get_for_section(user.osm_api, section_id).each do |member|
      if member.leader?
        member_lines.push "#{member.name} skipped as they are a leader."
        next member
      end
      if member.date_of_birth.nil?
        member_lines.push "#{member.name} skipped as they are missing a date of birth."
        next member
      end

      birthday = next_birthday_for_member(member, earliest)
      age = ((birthday - member.date_of_birth) / 365).to_i

      unless birthday.between?(earliest, latest)
        member_lines.push "#{member.name} skipped as their #{age.ordinalize} bithday is outside the range."
        next member
      end

      # We found a birthday
      member_lines.push "#{member.name}'s #{age.ordinalize} bithday is on #{birthday.strftime("%-d %B")}"
      birthdays.push({
        member: member,
        age: age,
        birthday: birthday
      })
    end # each member

    ret_val[:log_lines].push "Found #{birthdays.size > 0 ? birthdays.size : 'no'} #{birthdays.size.eql?(1) ? 'birthday' : 'birthdays'}."
    ret_val[:log_lines].push (birthday_lines = [])
    unless birthdays.empty?
      badges = Osm::CoreBadge.get_badges_for_section(user.osm_api, section_id)
      badges.select!{ |badge| configuration.values_at(:badge_6, :badge_7, :badge_8, :badge_9, :badge_10).include?(badge.id) }
      badge_datas = Hash[ badges.map{ |badge| [badge.id, badge.get_data_for_section(user.osm_api, section_id)] } ]
      badges = Hash[ badges.map{ |badge| [badge.id, badge] } ]

      birthdays.each do |birthday|
        member = birthday[:member]
        age = birthday[:age]
        badge = badges[configuration["badge_#{age}".to_sym]]
        data = badge_datas[badge.id].select{ |d| d.member_id.eql?(member.id) }.first

        unless data.awarded?
          unless data.due?

            begin
              if data.mark_due(user.osm_api, 1)
                birthday_lines.push "#{badge.name} has been marked due for #{member.name}."
              else
                birthday_lines.push "Error marking #{badge.name} as due for #{member.name}."
                ret_val[:errors].push "Error marking #{badge.name} as due for #{member.name}."
              end
            rescue Osm::Error => exception
              birthday_lines.push "Error marking #{badge.name} as due for #{member.name}. OSM said \"#{exception.message}\"."
              ret_val[:errors].push "Error marking #{badge.name} as due for #{member.name}. OSM said \"#{exception.message}\"."
            end

          else # already due
            birthday_lines.push "#{member.name} is already due the \"#{badge.name}\" badge."
          end
        else # already awarded
          birthday_lines.push "#{member.name} has already been awarded the \"#{badge.name}\" badge."
        end
      end # each birthday
    end

    ret_val.merge(success: ret_val[:errors].empty?)
  end

  def next_birthday_for_member(member, from=Date.current)
    year = from.year
    mmdd = member.date_of_birth.strftime('%m%d')
    year += 1 if mmdd < from.strftime('%m%d')
    mmdd = '0301' if mmdd == '0229' && !Date.parse("#{year}0101").leap?
    return Date.parse("#{year}#{mmdd}")
  end

end