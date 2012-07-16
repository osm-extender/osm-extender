class EmailReminderItemProgramme < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    data = []
    earliest = Date.today.to_date
    latest = configuration[:the_next_n_weeks].weeks.from_now.to_date

    terms = user.osm_api.get_terms
    terms.each do |term|
      if (term.section_id == section_id) && !term.before?(earliest) && !term.after?(latest)
        programme = user.osm_api.get_programme(section_id, term.id)
        programme.each do |programme_item|
          if (programme_item.meeting_date > earliest) && (programme_item.meeting_date < latest)
            item = {
              :start_time => programme_item.start_time,
              :end_time => programme_item.end_time,
              :date => programme_item.meeting_date,
              :title => programme_item.title,
              :activities => [],
            }
            programme_item.activities.each do |activity|
              item[:activities].push activity.title
            end
            data.push item
          end
        end
      end
    end

    return data.sort do |a, b|
      a[:date] <=> b[:date]
    end
  end


  def get_fake_data
    data = []
    dates = (Date.today.to_date..configuration[:the_next_n_weeks].weeks.from_now.to_date).step(7)
    dates.each_with_index do |date, index|
      item = {
        :start_time => '20:00',
        :end_time => '22:00',
        :date => date,
        :title => "Week #{index + 1}",
        :activities => [],
      }
      (1 + rand(3)).times do |activity|
        item[:activities].push Faker::Lorem.words(1 + rand(3)).join(' ')
      end
      data.push item
    end

    return data.sort do |a, b|
      a[:date] <=> b[:date]
    end
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
      :the_next_n_weeks => Fixnum,
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
      errors.add(:the_next_n_weeks, "must be greater than 0")
    end
    configuration = config
  end

end