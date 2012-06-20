class EmailReminderItemNotSeen < EmailReminderItem

  def get_data
    earliest = configuration[:the_last_n_weeks].weeks.ago.to_date

    api = user.osm_api
    register_structure = api.get_register_structure(section_id)
    register = api.get_register(section_id)

    dates_to_check = []
    register_structure[1][:rows].each do |row|
      dates_to_check.push row[:name] if (Date.parse(row[:name]) > earliest)
    end

    not_seen = []
    register.each do |member|
      not_seen.push ({
        :first_name => member[:firstname],
        :last_name => member[:lastname],
      }) unless seen_member_in?(member, dates_to_check)
    end
    return not_seen
  end

  def get_fake_data
    data = []

    (1 + rand(3)).times do
      data.push ({
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
      })
    end
    return data
  end

  def labels
    {
      :the_last_n_weeks => 'For how many weeks?',
    }
  end

  def default_configuration
    {
      :the_last_n_weeks => 2,
    }
  end

  def configuration_types
    {
      :the_last_n_weeks => Fixnum,
    }
  end

  def friendly_name
    return 'Members not seen'
  end


  private
  def seen_member_in?(member, dates_to_check)
    dates_to_check.each do |date|
      if member[date.to_sym].eql?('Yes') || member[date.to_sym].eql?('No') # Allowed absences are OK
        return true
      end
    end
    return false
  end

end