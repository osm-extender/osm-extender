class EmailReminderItemDueBadge < EmailReminderItem

  def get_data
    return user.osm_api.get_due_badges(section_id)
  end


  def get_fake_data
    data = {
      'pending' => {},
      'description' => {},
    }

    (1..(1 + rand(3))).each do |badge_num|
      data['description']["badge_#{badge_num}"] = {
        'name' => "#{badge_num.ordinalize} badge",
        'section' => 'fake',
        'type' => 'fake'
      }
      data['pending']["badge_#{badge_num}"] = []
      (1 + rand(8)).times do
        data['pending']["badge_#{badge_num}"].push ({
          'firstname' => Faker::Name.first_name,
          'lastname' => Faker::Name.last_name,
          'extra' => ((badge_num % 2) == 0) ? "Lvl #{1 + rand(4)}" : ''
        })
      end
    end

    return OSM::DueBadges.new(data)
  end


  def default_configuration
    {
    }
  end

  def human_name
    return 'Due badges'
  end

end