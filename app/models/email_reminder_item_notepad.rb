class EmailReminderItemNotepad < EmailReminderItem

  def get_data
    return Osm::Section.get(user.osm_api, section_id).get_notepad(user.osm_api)
  end

  def get_fake_data
    return Faker::Lorem.paragraph(1 + rand(3))
  end

  def self.required_permissions
    []
  end

  def self.default_configuration
    {
    }
  end

  def self.human_name
    return 'Section Notepad'
  end

end