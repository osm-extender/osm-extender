class EmailReminderItemNotSeen < EmailReminderItem

  def get_data
    data = []
    earliest = configuration[:the_last_n_weeks].weeks.ago.to_date

    api = user.osm_api
    register_structure = api.get_register_structure(section_id)[:data]
    register = api.get_register(section_id)[:data]

    dates_to_check = []
    register_structure[1][:rows].each do |row|
      dates_to_check.push row[:name] if (Date.parse(row[:name]) > earliest)
    end

    not_seen = []
    register.each do |member|
      not_seen.push member unless seen_member_in?(member, dates_to_check)
    end
    return not_seen
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
      return true if member[date.to_sym].eql?('1')
    end
    return false
  end

end