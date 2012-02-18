class EmailReminderItemDueBadge < EmailReminderItem

  def get_data
    return user.osm_api.get_due_badges(section_id)[:data]
  end


  def labels
    {
    }
  end

  def default_configuration
    {
    }
  end

  def configuration_types
    {
    }
  end

  def friendly_name
    return 'Due badges'
  end

end