class EmailReminderItemBirthday < EmailReminderItem

  def get_data
    data = []
    earliest = configuration[:the_last_n_months].months.ago.to_date
    latest = configuration[:the_next_n_months].months.from_now.to_date

    members = user.osm_api.get_members(section_id)
    members.each do |member|
      unless member.date_of_birth.nil?
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
    end

    return data.sort do |a, b|
      a[:birthday] <=> b[:birthday]
    end
  end


  def get_fake_data
    data = []
    earliest_date = -(Date.today - configuration[:the_last_n_months].months.ago.to_date).to_i
    date_range = (configuration[:the_next_n_months] + configuration[:the_last_n_months]).months  /  1.day

    (1 + rand(4)).times do
      data.push ({
        :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}",
        :birthday => (earliest_date + rand(date_range)).days.from_now.to_date,
        :age_on_birthday => (6 + rand(12))
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
    }
  end

  def self.default_configuration
    {
      :the_next_n_months => 1,
      :the_last_n_months => 2,
    }
  end

  def self.configuration_types
    {
      :the_next_n_months => Fixnum,
      :the_last_n_months => Fixnum,
    }
  end

  def self.human_name
    'Birthdays'
  end

  def human_configuration
    "From #{configuration[:the_last_n_months]} #{"month".pluralize(configuration[:the_last_n_months])} ago " +
    "to #{configuration[:the_next_n_months]} months time."
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