class EmailReminderItemNotSeen < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    earliest = configuration[:the_last_n_weeks].weeks.ago.to_date
    latest = Date.current

    api = user.osm_api
    register_structure = Osm::Register.get_structure(api, section_id)
    register = Osm::Register.get_attendance(api, section_id)

    dates_to_check = []
    register_structure.each do |row|
      unless /\A[0-9]{4}-[0-2][0-9]-[0-3][0-9]\Z/.match(row.name).nil?
        date = Date.strptime(row.name, '%Y-%m-%d')
        dates_to_check.push date if (date >= earliest) && (date <= latest)
      end
    end

    not_seen = []
    register.each do |row|
      unless configuration[:include_leaders]  # User has chosen to exclude leaders
        if row.grouping_id.eql?(-2)           # Member this row represents is in the leaders patrol
          next row
        end
      end

      if not_seen_member_in?(row.attendance, dates_to_check)
        not_seen.push ({
          :first_name => row.first_name,
          :last_name => row.last_name,
        })
      end
    end # each row
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


  def self.required_permissions
    [:read, :register]
  end

  def self.configuration_labels
    {
      the_last_n_weeks: 'For how many weeks?',
      include_leaders: 'Include leaders?'
    }
  end

  def self.default_configuration
    {
      the_last_n_weeks: 2,
      include_leaders: true
    }
  end

  def self.configuration_types
    {
      the_last_n_weeks: :positive_integer,
      include_leaders: :boolean
    }
  end

  def self.human_name
    return 'Members not seen'
  end

  def human_configuration
    "In the last #{configuration[:the_last_n_weeks]} #{"week".pluralize(configuration[:the_last_n_weeks])}" +
    "#{', excluding leaders' unless configuration[:include_leaders]}."
  end


  private
  def not_seen_member_in?(attendance, dates_to_check)
    return false if dates_to_check.empty?
    dates_to_check.each do |date|
      if [:yes, :advised_absent].include?(attendance[date]) # Advised absences are OK
        return false
      end
    end
    return true
  end

  def configuration_is_valid
    config = configuration
    unless config[:the_last_n_weeks] > 0
      errors.add('For how many weeks?', 'Must be greater than 0')
      config[:the_last_n_weeks] = self.class.default_configuration[:the_last_n_weeks]
    end
    self.configuration = config
  end

end
