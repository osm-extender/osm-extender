class EmailReminderItemEvent < EmailReminderItem

  def get_data
    data = []

    events = user.osm_api.get_events(section_id)
    events.each do |event|
      unless event.start.nil?
        if (event.start < configuration[:the_next_n_months].months.from_now)  &&  (event.start > Time.now)
          data.push event
        end
      end
    end

    return data.sort do |a, b|
      a.start <=> b.start
    end
  end


  def get_fake_data
    data = []

    (1 + rand(3)).times do
      start_datetime = rand(configuration[:the_next_n_months].months / 1.day).days.from_now.to_datetime
      end_datetime = start_datetime + 2.days - 6.hours
      data.push Osm::Event.new({
        :name => Faker::Lorem.words(2 + rand(3)).join(' '),
        :start => start_datetime,
        :end => end_datetime
      })
    end

    return data.sort do |a, b|
      a.start <=> b.start
    end
  end


  def self.configuration_labels
    {
      :the_next_n_months => 'How many months into the future?',
    }
  end

  def self.default_configuration
    {
      :the_next_n_months => 3,
    }
  end

  def self.configuration_types
    {
      :the_next_n_months => :positive_integer,
    }
  end

  def self.human_name
    return 'Events'
  end

  def human_configuration
    "For the next #{configuration[:the_next_n_months]} months."
  end

end
