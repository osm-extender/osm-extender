class EmailReminderItemEvent < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    events = []
    Osm::Event.get_for_section(user.osm_api, section_id).each do |event|
      unless event.start.nil?
        if (event.start < configuration[:the_next_n_months].months.from_now)  &&  (event.start > Time.now)
          events.push event
        end
      end
    end

    attendance = {}
    if configuration[:include_attendance]
      events.each do |e|
        h = {
          :yes => {:leaders=>0, :members=>0, :total=>0},
          :no => {:leaders=>0, :members=>0, :total=>0},
          :invited => {:leaders=>0, :members=>0, :total=>0},
          :shown => {:leaders=>0, :members=>0, :total=>0},
          :reserved => {:leaders=>0, :members=>0, :total=>0},
        }
        e.get_attendance(user.osm_api, section_id).each do |a|
          h[a.attending][a.grouping_id == -2 ? :leaders : :members] += 1
          h[a.attending][:total] += 1
        end
        attendance[e.id] = h
      end
    end

    return events.empty? ? nil : {
      :events => events.sort,
      :attendance => attendance,
    }
  end


  def get_fake_data
    events = []
    attendance = {}

    (1 + rand(3)).times do |i|
      start_datetime = rand(configuration[:the_next_n_months].months / 1.day).days.from_now.to_datetime
      confirm_date = (start_datetime - (rand(12) + 2).days).to_date
      end_datetime = start_datetime + rand(2).days + 18.hours
      events.push Osm::Event.new({
        :name => Faker::Lorem.words(2 + rand(3)).join(' '),
        :start => start_datetime,
        :end => end_datetime,
        :confirm_by_date => confirm_date,
        :id => i,
      })
      attendance[i] = {
        :yes => {:leaders=>rand(2)+2, :members=>rand(10)},
        :no => {:leaders=>rand(2), :members=>rand(10)},
        :invited => {:leaders=>rand(2), :members=>rand(5)},
        :shown => {:leaders=>rand(2), :members=>rand(5)},
        :reserved => {:leaders=>rand(2), :members=>rand(3)},
      }
      attendance[i].keys.each do |k|
        attendance[i][k][:total] = attendance[i][k][:leaders] + attendance[i][k][:members]
      end
    end

    return {
      :events => events.sort,
      :attendance => attendance,
    }
  end


  def self.configuration_labels
    {
      :the_next_n_months => 'How many months into the future?',
      :include_attendance => 'Include attendance breakdown?',
    }
  end

  def self.default_configuration
    {
      :the_next_n_months => 3,
      :include_attendance => false,
    }
  end

  def self.configuration_types
    {
      :the_next_n_months => :positive_integer,
      :include_attendance => :boolean,
    }
  end

  def self.human_name
    return 'Events'
  end

  def human_configuration
    "For the next #{configuration[:the_next_n_months]} months, #{configuration[:include_attendance] ? 'with' : 'without'} attendance breakdown."
  end


  private
  def configuration_is_valid
    config = configuration
    unless config[:the_next_n_months] > 0
      errors.add('How many months into the future?', 'Must be greater than 0')
      config[:the_next_n_months] = self.class.default_configuration[:the_next_n_months]
    end
    unless [true, false].include?(config[:include_attendance])
      errors.add('Include attendance breakdown?', 'Invalid option')
      config[:include_attendance] = self.class.default_configuration[:include_attendance]
    end
    self.configuration = config
  end

end
