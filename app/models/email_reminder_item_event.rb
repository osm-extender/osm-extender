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
      date = rand(configuration[:the_next_n_months].months / 1.day).days.from_now.strftime('%y-%m-%d')
      data.push OSM::Event.new({
        'name' => Faker::Lorem.words(2 + rand(3)).join(' '),
        'startdate' => date,
        'starttime' => "1#{rand(9)}:00",
        'enddate' => date,
        'endtime' => "2#{rand(4)}:00",
      })
    end

    return data.sort do |a, b|
      a.start <=> b.start
    end
  end


  def configuration_labels
    {
      :the_next_n_months => 'How many months into the future?',
    }
  end

  def default_configuration
    {
      :the_next_n_months => 3,
    }
  end

  def configuration_types
    {
      :the_next_n_months => Fixnum,
    }
  end

  def human_name
    return 'Events'
  end

  def human_configuration
    "For the next #{configuration[:the_next_n_months]} months."
  end

end