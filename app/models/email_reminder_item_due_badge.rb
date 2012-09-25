class EmailReminderItemDueBadge < EmailReminderItem

  def get_data
    return {
      :due_badges => user.osm_api.get_due_badges(section_id),
      :badge_stock => configuration[:show_stock] ? user.osm_api.get_badge_stock_levels(section_id) : {}
    }
  end


  def get_fake_data
    descriptions = {}
    by_member = {}
    badge_stock = {}
    
    badges_generated = (1 + rand(3))

    (1 + rand(8)).times do
      member_name = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
      by_member[member_name] ||= []
      (1..badges_generated).each do |badge_num|
        badge_name = "#{badge_num.ordinalize} badge"
        badge_tag = "badge_#{badge_num}"
        descriptions[badge_tag] = badge_name
        by_member[member_name].push(badge_tag) if (rand(10) % 3) >= 1
      end
    end

    descriptions.each_key do |badge_tag|
      badge_stock[badge_tag] = rand(10)
    end

    by_member = by_member.select{ |k,v| !v.empty? }

    return {
      :due_badges => Osm::DueBadges.new(:by_member => by_member, :descriptions => descriptions),
      :badge_stock => badge_stock
    }
  end


  def self.configuration_labels
    {
      :show_stock => 'Show stock level of badges?',
    }
  end

  def self.default_configuration
    {
      :show_stock => false
    }
  end

  def self.configuration_types
    {
      :show_stock => :boolean,
    }
  end

  def self.human_name
    return 'Due badges'
  end

  def human_configuration
    "#{configuration[:show_stock] ? 'With' : 'Without'} badge stock levels."
  end

end