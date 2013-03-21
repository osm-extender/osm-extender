class EmailReminderItemAdvisedAbsence < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    latest = configuration[:the_next_n_weeks].weeks.from_now.to_date
    earliest = Date.today

    api = user.osm_api
    register_structure = Osm::Register.get_structure(api, section_id)
    register = Osm::Register.get_attendance(api, section_id).sort

    dates_to_check = []
    register_structure.each do |row|
      unless /\A[0-9]{4}-[0-2][0-9]-[0-3][0-9]\Z/.match(row.name).nil?
        date = Date.strptime(row.name, '%Y-%m-%d')
        dates_to_check.push date if (date >= earliest) && (date <= latest)
      end
    end

    data = {
      :total_leaders => 0,
      :total_members => 0,
      :dates => {},
    }
    register.each do |row|
      data[(row.grouping_id == -2) ? :total_leaders : :total_members] += 1
      dates_to_check.each do |date|
        if row.attendance[date].eql?('No')
          data[:dates][date] ||= []
          data[:dates][date].push({
            :first_name => row.first_name,
            :last_name => row.last_name,
            :leader => (row.grouping_id == -2)
          })
        end
      end
    end
    return data[:dates].empty? ? nil : data
  end

  def get_fake_data
    data = {
      :total_leaders => 2 + rand(4),
      :total_members => 4 + rand(20),
      :dates => {},
    }

    (1 + rand(3)).times do
      people = []
      (1 + rand(3)).times do
        people.push ({
          :first_name => Faker::Name.first_name,
          :last_name => Faker::Name.last_name,
          :leader => (rand(4) < 2),
        })
      end
      date = rand(configuration[:the_next_n_weeks] * 7).days.from_now.to_date
      data[:dates][date] = people
    end

    return data
  end

  def self.configuration_labels
    {
      :the_next_n_weeks => 'For how many weeks?',
    }
  end

  def self.default_configuration
    {
      :the_next_n_weeks => 2,
    }
  end

  def self.configuration_types
    {
      :the_next_n_weeks => :positive_integer,
    }
  end

  def self.human_name
    return 'Advised absences'
  end

  def human_configuration
    "For the next #{configuration[:the_next_n_weeks]} #{"week".pluralize(configuration[:the_next_n_weeks])}."
  end


  private
  def configuration_is_valid
    config = configuration
    unless config[:the_next_n_weeks] > 0
      errors.add('For how many weeks?', 'Must be greater than 0')
      config[:the_next_n_weeks] = self.class.default_configuration[:the_next_n_weeks]
    end
    self.configuration = config
  end

end