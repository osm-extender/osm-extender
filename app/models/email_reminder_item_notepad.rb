class EmailReminderItemNotepad < EmailReminderItem

  def get_data
    return user.osm_api.get_notepad(section_id)
  end

  def get_fake_data
    return Faker::Lorem.paragraph(1 + rand(3))
  end

  def default_configuration
    {
    }
  end

  def human_name
    return 'Section Notepad'
  end

end