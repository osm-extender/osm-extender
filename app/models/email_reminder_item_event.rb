class EmailReminderItemEvent < EmailReminderItem

  def get_data
    data = []

    events = user.osm_api.get_events(section_id)[:data]
    events.each do |event|
      unless event.start.nil?
        if (event.start < configuration[:the_next_n_months].months.from_now)  &&  (event.start > Time.now)
          data.push event
        end
      end
    end

    data.sort! do |a, b|
      a.start <=> b.start
    end
    return data
  end


  def labels
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

  def friendly_name
    return 'Events'
  end

end