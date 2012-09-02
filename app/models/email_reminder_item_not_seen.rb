class EmailReminderItemNotSeen < EmailReminderItem

  def get_data
    earliest = configuration[:the_last_n_weeks].weeks.ago.to_date

    api = user.osm_api
    register_structure = api.get_register_structure(section_id)
    register = api.get_register_data(section_id)

    dates_to_check = []
    register_structure.each do |row|
      unless /\A[0-9]{4}-[0-2][0-9]-[0-3][0-9]\Z/.match(row.name).nil?
        date = Date.strptime(row.name, '%Y-%m-%d')
        dates_to_check.push date if (date > earliest)
      end
    end

    not_seen = []
    register.each do |row|
      not_seen.push ({
        :first_name => row.first_name,
        :last_name => row.last_name,
      }) if not_seen_member_in?(row, dates_to_check)
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
      was_there = member.attendance[date]
      if was_there.eql?('Yes') || was_there.eql?('No') # Allowed absences are OK
        return false
      end
    end
    return true
  end

end