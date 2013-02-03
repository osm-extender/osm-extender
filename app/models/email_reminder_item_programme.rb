class EmailReminderItemProgramme < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    data = []
    earliest = Date.today.to_date
    latest = configuration[:the_next_n_weeks].weeks.from_now.to_date

    Osm::Term.get_for_section(user.osm_api, section_id).each do |term|
      if !term.before?(earliest) && !term.after?(latest)
        programme = Osm::Evening.get_programme(user.osm_api, section_id, term.id)
        programme.each do |programme_item|
          if (programme_item.meeting_date > earliest) && (programme_item.meeting_date < latest)
            data.push programme_item
          end
        end
      end
    end

    return data.sort do |a, b|
      a.meeting_date <=> b.meeting_date
    end # TODO - replace with just sort after upping osm to 0.1.17 or higher
  end


  def get_fake_data
    data = []
    dates = (Date.today.to_date..configuration[:the_next_n_weeks].weeks.from_now.to_date).step(7)
    dates.each_with_index do |date, index|
      activities = []
      (1 + rand(3)).times do |activity|
        title = Faker::Lorem.words(1 + rand(3)).join(' ')
        notes = (rand(2) == 1) ? Faker::Lorem.words(1 + rand(7)).join(' ') : ''
        activities.push Osm::Evening::Activity.new(:title => title, :notes => notes)
      end
      item = Osm::Evening.new(
        :start_time => '20:00',
        :finish_time => '22:00',
        :meeting_date => date,
        :title => "Week #{index + 1}",
        :activities => activities,
      )
      data.push item
    end

    return data.sort do |a, b|
      a.meeting_date <=> b.meeting_date
    end # TODO - replace with just sort after upping osm to 0.1.17 or higher
  end


  def self.configuration_labels
    {
      :the_next_n_weeks => 'How many weeks into the future?',
    }
  end

  def self.default_configuration
    {
      :the_next_n_weeks => 4,
    }
  end

  def self.configuration_types
    {
      :the_next_n_weeks => :positive_integer,
    }
  end

  def self.human_name
    return 'Programme'
  end

  def human_configuration
    "For the next #{configuration[:the_next_n_weeks]} #{"week".pluralize(configuration[:the_next_n_weeks])}."
  end


  private
  def configuration_is_valid
    config = configuration
    unless config[:the_next_n_weeks] > 0
      errors.add('How many weeks into the future?', 'Must be greater than 0')
      config[:the_next_n_weeks] = self.class.default_configuration[:the_next_n_weeks]
    end
    self.configuration = config
  end

end