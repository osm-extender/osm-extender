class EmailReminderItemProgramme < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    data = []
    earliest = Date.today
    latest = configuration[:the_next_n_weeks].weeks.from_now

    terms = user.osm_api.get_terms[:data]
    terms.each do |term|
      if (term.section_id == section_id) && !term.before?(earliest) && !term.after?(latest)
        programme = user.osm_api.get_programme(section_id, term.id)[:data]
        programme.each do |programme_item|
          if (programme_item.start > earliest) && (programme_item.start < latest)
            item = {
              :start => programme_item.start,
              :end => programme_item.end,
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

    data.sort! do |a, b|
      a[:start] <=> b[:start]
    end
    return data
  end


  def labels
    {
      :the_next_n_weeks => 'How many weeks into the future?',
    }
  end

  def default_configuration
    {
      :the_next_n_weeks => 4,
    }
  end

  def configuration_types
    {
      :the_next_n_weeks => Fixnum,
    }
  end

  def friendly_name
    return 'Programme'
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