class EmailReminderItemBirthday < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    data = []
    earliest = configuration[:the_last_n_months].months.ago.to_date
    latest = configuration[:the_next_n_months].months.from_now.to_date

    members = Osm::Member.get_for_section(user.osm_api, section_id)
    members.each do |member|
      leader = member.grouping_id.eql?(-2)
      next if leader && !configuration[:include_leaders]
      next if member.date_of_birth.nil?

      birthday = next_birthday_for_member(member, earliest)
      age = ((birthday - member.date_of_birth) / 365).to_i
      if birthday < latest
        data.push({
          :name => member.name,
          :birthday => birthday,
          :age_on_birthday => !(leader && !configuration[:include_leaders_age]) ? age : nil
        })
      end
    end

    return data.sort do |a, b|
      a[:birthday] <=> b[:birthday]
    end
  end


  def get_fake_data
    data = []
    earliest_date = -(Date.current - configuration[:the_last_n_months].months.ago.to_date).to_i
    date_range = (configuration[:the_next_n_months] + configuration[:the_last_n_months]).months  /  1.day

    (1 + rand(4)).times do
      data.push ({
        :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}",
        :birthday => (earliest_date + rand(date_range)).days.from_now.to_date,
        :age_on_birthday => (6 + rand(12))
      })
    end
    if configuration[:include_leaders]
      data.push ({
        :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}",
        :birthday => (earliest_date + rand(date_range)).days.from_now.to_date,
        :age_on_birthday => configuration[:include_leaders_age] ? (18 + rand(40)) : nil
      })
    end

    return data.sort do |a, b|
      a[:birthday] <=> b[:birthday]
    end
  end


  def self.configuration_labels
    {
      :the_next_n_months => 'How many months into the future?',
      :the_last_n_months => 'How many months into the past?',
      :include_leaders => 'Include leaders?',
      :include_leaders_age => "Include leaders' ages?",
    }
  end

  def self.default_configuration
    {
      :the_next_n_months => 1,
      :the_last_n_months => 2,
      :include_leaders => true,
      :include_leaders_age => true,
     }
  end

  def self.configuration_types
    {
      :the_next_n_months => :positive_integer,
      :the_last_n_months => :positive_integer,
      :include_leaders => :boolean,
      :include_leaders_age => :boolean,
    }
  end

  def self.human_name
    'Birthdays'
  end

  def human_configuration
    "From #{configuration[:the_last_n_months]} #{"month".pluralize(configuration[:the_last_n_months])} ago " +
    "to #{configuration[:the_next_n_months]} months time. " +
    "#{configuration[:include_leaders] ? 'Including' : 'Not incuding'} leaders#{" but not their ages" if (configuration[:include_leaders] && !configuration[:include_leaders_age])}."
  end


  private
  def next_birthday_for_member(member, from=Date.current)
    year = from.year
    mmdd = member.date_of_birth.strftime('%m%d')
    year += 1 if mmdd < from.strftime('%m%d')
    mmdd = '0301' if mmdd == '0229' && !Date.parse("#{year}0101").leap?
    return Date.parse("#{year}#{mmdd}")
  end

  def configuration_is_valid
    config = configuration
    unless config[:the_last_n_months] > 0
      errors.add('How many months into the past?', 'Must be greater than 0')
      config[:the_last_n_months] = self.class.default_configuration[:the_last_n_months]
    end
    unless config[:the_next_n_months] > 0
      errors.add('How many months into the future?', 'Must be greater than 0')
      config[:the_next_n_months] = self.class.default_configuration[:the_next_n_months]
    end
    self.configuration = config
  end

end
