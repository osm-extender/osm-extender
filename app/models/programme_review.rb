class ProgrammeReview

  # Hashes for tags, each key is a symbol refering to a section each value an array
  # of arrays containging the label and alternative tags

  # Programme Zones for each section
  @@zones = {
    :beavers   => [
      ['Beliefs and attitudes', 'belief', 'attitude', 'beliefs', 'attitudes'],
      ['Community'],
      ['Fitness'],
      ['Creative'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure', 'outdoors']
    ],
    :cubs      => [
      ['Beliefs and attitudes', 'belief', 'attitude', 'beliefs', 'attitudes'],
      ['Community'],
      ['Fitness'],
      ['Creative'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure', 'outdoors']
    ],
    :scouts    => [
      ['Beliefs and attitudes', 'belief', 'attitude', 'beliefs', 'attitudes'],
      ['Community'],
      ['Fit for life'],
      ['Creative expression', 'creative', 'expression', 'outdoors'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure', 'outdoors']
    ],
    :explorers => [
      ['Values and relationships', 'value', 'relationship', 'values', 'relationships'],
      ['Community service', 'community', 'service'],
      ['Physical recreation'],
      ['Skills'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure']
    ]
  }
  # Programme Methods for each section
  @@methods = {
    :beavers   => [
      ['Help others'],
      ['Go on visits', 'visit'],
      ['Play games', 'game'],
      ['Make things', 'make'],
      ['Meet new people'],
      ['Act, sing and make music', 'act', 'sing', 'music', 'acting', 'singing'],
      ['Listen to stories', 'stories', 'story'],
      ['Prayer and worship', 'prayer', 'worship'],
      ['Chat'],
      ['Follow themes', 'themes'],
      ['Go outdoors', 'outdoors']
    ],
    :cubs      => [
      ['Make things', 'make'],
      ['Singing, stories and drama', 'act', 'sing', 'music', 'acting', 'singing', 'drama', 'story', 'stories'],
      ['Visits and visitors', 'visits', 'visit', 'visitor', 'visitors'],
      ['Outdoors'],
      ['Activities with others'],
      ['Help other people', 'help others'],
      ['Themes'],
      ['Prayer, worship and reflection', 'prayer', 'worship', 'reflection'],
      ['Team challenges', 'team challenge'],
      ['Try new things']
    ],
    :scouts    => [
      ['Activities outdoors', 'outdoors'],
      ['Games', 'game'],
      ['Design and creativity', 'design', 'creativity'],
      ['Visits and visitors', 'visits', 'visit', 'visitor', 'visitors'],
      ['Service'],
      ['Technology and new skills', 'technology', 'new skill', 'new skills'],
      ['Team building activities', 'Team builiding'],
      ['Activities with others'],
      ['Themes'],
      ['Prayer, worship and reflection', 'prayer', 'worship', 'reflection']
    ],
    :explorers => [
      ['Visits'],
      ['Games', 'game'],
      ['Outdoor activities', 'outdoors'],
      ['Residential experiances', 'residential'],
      ['Technology'],
      ['Networking activities', 'networking'],
      ['Discussion']
    ]
  }

  #Section duration - the number of time a young member will expect to be in each section
  @@section_duration = {
    :beavers => 2.years,
    :cubs => 30.months,   # 2 and a half years
    :scouts => 42.months, # 3 and a half years
    :explorers => 4.years,
  }


  def initialize(user, section)
    @user = user
    @section = section
  end


  def balanced(start=@@section_duration[@section.type].ago, finish=@@section_duration[@section.type].from_now)
    zones = {:number => {}, :time => {}}
    methods = {:number => {}, :time => {}}
    earliest = Date.today
    latest = Date.today

    get_terms.each do |term|
      next if term.before?(start) || term.after?(finish)
      earliest = term.start if term.start < earliest
      latest = term.end if term.end > latest

      cached_term_data = ProgrammeReviewBalancedCache.find_by_term_id(term.id)
      if cached_term_data.nil? || cached_term_data.data[:version] != 1
        # We need to make it
        data = get_balanced_term_data(term)

        # Cache it if the term is in the past
        if term.past?
          cached_term_data = ProgrammeReviewBalancedCache.create({
            :term_id => term.id,
            :section_id => term.section_id,
            :data => data,
            :last_used_at => Time.now,
          })
          cached_term_data.save
        end
      else
        # Use cahed data
        cached_term_data.last_used_at = Time.now
        cached_term_data.save
        data = cached_term_data.data
      end

      term_methods = data[:methods]
      term_zones = data[:zones]

      # Add term data into totals
      [:number, :time].each do |num_or_time|
        term_methods[:number].each_key do |date_key|
          methods[num_or_time][date_key] = blank_hash_for(@@methods) if methods[num_or_time][date_key].nil?
          term_methods[num_or_time][date_key].each_key do |method|
            methods[num_or_time][date_key][method] += term_methods[num_or_time][date_key][method]
          end
        end
        term_zones[num_or_time].each_key do |date_key|
          zones[num_or_time][date_key] = blank_hash_for(@@zones) if zones[num_or_time][date_key].nil?
          term_zones[:number][date_key].each_key do |zone|
            zones[num_or_time][date_key][zone] += term_zones[num_or_time][date_key][zone]
          end
        end
      end

    end

    # Ensure that all months are covered
    (earliest.year..latest.year).each do |year|
      (((earliest.year==year) ? earliest.month : 1)..((latest.year==year) ? latest.month : 12)).each do |month|
        date_key = "#{year}_#{"%02d" % month}"
        zones[:number][date_key] = blank_hash_for(@@zones) if zones[:number][date_key].nil?
        methods[:number][date_key] = blank_hash_for(@@methods) if methods[:number][date_key].nil?
        zones[:time][date_key] = blank_hash_for(@@zones) if zones[:time][date_key].nil?
        methods[:time][date_key] = blank_hash_for(@@methods) if methods[:time][date_key].nil?
      end
    end

    return {
      :zones => zones,
      :methods => methods,
      :zone_labels => @@zones[@section.type].clone,
      :method_labels => @@methods[@section.type].clone,
      :statistics => {
        :earliest_date => earliest,
        :latest_date => latest,
        :zones => get_balanced_statistics(zones, @@zones),
        :methods => get_balanced_statistics(methods, @@methods),
      }
    }
  end

  def self.zones
    return @@zones.clone
  end

  def self.methods
    return @@methods.clone
  end


  private
  def get_terms
    terms = []
    @user.osm_api.get_terms.each do |term|
      terms.push term if term.section_id == @section.id
    end
    return terms
  end


  def tags_in_array(tags, array)
    tags_in_array_r = []

    array.each do |method_or_zone|
      tags.each do |tag|
        tags_in_array_r.push method_or_zone if similar?(method_or_zone, tag)
      end
    end

    return tags_in_array_r
  end

  def similar?(a, b)
    if a.is_a? Array
      a.each do |item|
        return true if similar?(item, b)
      end
    end

    if b.is_a? Array
      b.each do |item|
        return true if similar?(a, item)
      end
    end

    if a.is_a?(String)  &&  b.is_a?(String)
      a = a.downcase.gsub(/[^a-z0-9]/, '')
      b = b.downcase.gsub(/[^a-z0-9]/, '')
      return a.eql?(b)
    end

    return false
  end

  def blank_hash_for(zones_or_methods)
    to_return = {}

    zones_or_methods[@section.type].each do |key|
      key = key[0]
      to_return[key] = 0
    end

    return to_return
  end

  def get_balanced_term_data(term)
    zones = {:number => {}, :time => {}}
    methods = {:number => {}, :time => {}}

    @user.osm_api.get_programme(term.section_id, term.id).each do |programme|
      date_key = programme.meeting_date.strftime('%Y_%m')
      zones[:number][date_key] = blank_hash_for(@@zones) if zones[:number][date_key].nil?
      zones[:time][date_key] = blank_hash_for(@@zones) if zones[:time][date_key].nil?
      methods[:number][date_key] = blank_hash_for(@@methods) if methods[:number][date_key].nil?
      methods[:time][date_key] = blank_hash_for(@@methods) if methods[:time][date_key].nil?

      programme.activities.each do |activity|
        activity_details = @user.osm_api.get_activity(activity.activity_id)
        unless activity_details.nil?
          tags_in_array(activity_details.tags, @@zones[@section.type]).each do |tag|
            zone_or_method = tag[0]
            zones[:number][date_key][zone_or_method] += 1
            zones[:time][date_key][zone_or_method] += activity_details.running_time
          end
          tags_in_array(activity_details.tags, @@methods[@section.type]).each do |tag|
            zone_or_method = tag[0]
            methods[:number][date_key][zone_or_method] += 1
            methods[:time][date_key][zone_or_method] += activity_details.running_time
          end
        end
      end
    end

    return {
      :version => 1,
      :zones => zones,
      :methods => methods
    }
  end

  def get_balanced_statistics(data, type)
    statistics = {}

    [:number, :time].each do |num_or_time|
      statistics[num_or_time] = {
        :max_value => 0,
        :standard_deviation => 0,
        :count_tags => 0,
        :total_tags => 0,
        :totals => blank_hash_for(type),
        :mean => 0,
        :standard_deviation => 0,
      }

      # Get information from data
      data[num_or_time].each_key do |date_key|
        data[num_or_time][date_key].each_key do |tag|
          statistics[num_or_time][:totals][tag] += data[num_or_time][date_key][tag]
          statistics[num_or_time][:total_tags] += data[num_or_time][date_key][tag]
          statistics[num_or_time][:max_value] = data[num_or_time][date_key][tag] if (statistics[num_or_time][:max_value] < data[num_or_time][date_key][tag])
        end
      end

      # Calculate mean
      statistics[num_or_time][:totals].each_key do |key|
        statistics[num_or_time][:count_tags] += statistics[num_or_time][:totals][key]
      end
      statistics[num_or_time][:mean] = statistics[num_or_time][:total_tags] / statistics[num_or_time][:count_tags] unless (statistics[num_or_time][:count_tags] == 0)

      # Calculate standard deviation
      unless statistics[num_or_time][:count_tags] == 0
        variance = 0
        statistics[num_or_time][:totals].each_key do |key|
          variance += (statistics[num_or_time][:totals][key] - statistics[num_or_time][:mean]) ** 2
        end
        variance = variance / statistics[num_or_time][:count_tags]
        statistics[num_or_time][:standard_deviation] = Math.sqrt(variance)
      end
    end

    statistics[:time][:totals].each_key do |tag|
      minutes = statistics[:time][:totals][tag]
      statistics[:time][:totals][tag] = "#{minutes / 60} hrs  #{minutes % 60} min"
    end

    return statistics
  end

end
