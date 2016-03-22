class EmailReminderItemProgramme < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    data = []
    earliest = Date.current.to_date
    latest = configuration[:the_next_n_weeks].weeks.from_now.to_date

    Osm::Term.get_for_section(user.osm_api, section_id).each do |term|
      if !term.before?(earliest) && !term.after?(latest)
        programme = Osm::Meeting.get_for_section(user.osm_api, section_id, term.id)
        programme.each do |programme_item|
          if (programme_item.date > earliest) && (programme_item.date < latest)
            data.push programme_item
          end
        end
      end
    end

    return data.sort
  end


  def get_fake_data
    data = []
    dates = (Date.current.to_date..configuration[:the_next_n_weeks].weeks.from_now.to_date).step(7)
    dates.each_with_index do |date, index|
      activities = []
      (1 + rand(3)).times do |activity|
        title = Faker::Lorem.words(1 + rand(3)).join(' ')
        notes = (rand(2) == 1) ? Faker::Lorem.words(1 + rand(7)).join(' ') : ''
        activities.push Osm::Meeting::Activity.new(:title => title, :notes => notes)
      end
      item = Osm::Meeting.new(
        :start_time => '20:00',
        :finish_time => '22:00',
        :date => date,
        :title => "Week #{index + 1}",
        :activities => activities,
      )
      data.push item
    end

    return data.sort
  end


  def self.required_permissions
    [:read, :programme]
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
