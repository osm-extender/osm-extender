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
        :first_name => member['firstname'],
        :last_name => member['lastname'],
      }) if not_seen_member_in?(member, dates_to_check)
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

  def self.configuration_labels
    {
      :the_last_n_weeks => 'For how many weeks?',
    }
  end

  def self.default_configuration
    {
      :the_last_n_weeks => 2,
    }
  end

  def self.configuration_types
    {
      :the_last_n_weeks => Fixnum,
    }
  end

  def self.human_name
    return 'Members not seen'
  end

  def human_configuration
    "In the last #{configuration[:the_last_n_weeks]} #{"week".pluralize(configuration[:the_last_n_weeks])}."
  end


  private
  def not_seen_member_in?(member, dates_to_check)
    return false if dates_to_check.empty?
    dates_to_check.each do |date|
      if member[date].eql?('Yes') || member[date].eql?('No') # Allowed absences are OK
        return false
      end
    end
    return true
  end

end