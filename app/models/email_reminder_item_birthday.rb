class EmailReminderItemBirthday < EmailReminderItem

  def get_data
    data = []
    earliest = configuration[:the_last_n_months].months.ago.to_date
    latest = configuration[:the_next_n_months].months.from_now.to_date

    members = user.osm_api.get_members(section_id)[:data]
    members.each do |member|
      birthday = next_birthday_for_member(member, earliest)
      if birthday < latest
        item = {
          :name => member.name,
          :birthday => birthday,
          :age_on_birthday => ((birthday - member.date_of_birth) / 365).to_i,
        }
        data.push item
      end
    end

    data.sort! do |a, b|
      a[:birthday] <=> b[:birthday]
    end
    return data
  end


  def labels
    {
      :the_next_n_months => 'How many months into the future?',
      :the_last_n_months => 'How many months into the past?',
    }
  end

  def default_configuration
    {
      :the_next_n_months => 1,
      :the_last_n_months => 2,
    }
  end

  def configuration_types
    {
      :the_next_n_months => Fixnum,
      :the_last_n_months => Fixnum,
    }
  end

  def friendly_name
    return 'Birthdays'
  end

  private
  def next_birthday_for_member(member, from=Date.today)
    year = from.year
    mmdd = member.date_of_birth.strftime('%m%d')
    year += 1 if mmdd < from.strftime('%m%d')
    mmdd = '0301' if mmdd == '0229' && !Date.parse("#{year}0101").leap?
    return Date.parse("#{year}#{mmdd}")
  end
end