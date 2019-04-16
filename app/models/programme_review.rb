class ProgrammeReview

  # Hashes for tags, each key is a symbol refering to a section each value an array
  # of arrays containging the label and alternative tags

  # Programme Zones for each section
  ZONES = {
    beavers: [
      ['Beliefs and attitudes', 'belief', 'attitude', 'beliefs', 'attitudes'],
      ['Community'],
      ['Fitness'],
      ['Creative'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure', 'outdoors']
    ],
    cubs: [
      ['Beliefs and attitudes', 'belief', 'attitude', 'beliefs', 'attitudes'],
      ['Community'],
      ['Fitness'],
      ['Creative'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure', 'outdoors']
    ],
    scouts: [
      ['Beliefs and attitudes', 'belief', 'attitude', 'beliefs', 'attitudes'],
      ['Community'],
      ['Fit for life'],
      ['Creative expression', 'creative', 'expression', 'outdoors'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure', 'outdoors']
    ],
    explorers: [
      ['Values and relationships', 'value', 'relationship', 'values', 'relationships'],
      ['Community service', 'community', 'service'],
      ['Physical recreation'],
      ['Skills'],
      ['Global'],
      ['Outdoor and adventure', 'outdoor', 'adventure']
    ]
  }.freeze

  # Programme Methods for each section
  METHODS = {
    beavers: [
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
    cubs: [
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
    scouts: [
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
    explorers: [
      ['Visits'],
      ['Games', 'game'],
      ['Outdoor activities', 'outdoors'],
      ['Residential experiances', 'residential'],
      ['Technology'],
      ['Networking activities', 'networking'],
      ['Discussion']
    ]
  }.freeze

  #Section duration - the number of time a young member will expect to be in each section
  SECTION_DURATION = {
    beavers: 2.years,
    cubs: 30.months,   # 2 and a half years
    scouts: 42.months, # 3 and a half years
    explorers: 4.years,
  }.freeze


  def initialize(user, section)
    @user = user
    @section = section
  end


  def balanced(start=SECTION_DURATION[@section.type].ago, finish=SECTION_DURATION[@section.type].from_now)
    zones = {:number => {}, :time => {}}
    methods = {:number => {}, :time => {}}
    earliest = Date.current
    latest = Date.current

    terms = Osm::Term.get_for_section(@user.osm_api, @section.id)
                     .reject { |term| term.before?(start) || term.after?(finish) }

    cached_terms = ProgrammeReviewBalancedCache.where(term_id: terms)
                                               .group_by(&:term_id)

    terms.each do |term|
      earliest = term.start if term.start < earliest
      latest = term.finish if term.finish > latest

      # Get/generate cached data
      cached_term = cached_terms[term.id]&.first
      if cached_term.nil?
        # Didn't exist, make a temporary one
        cached_term = ProgrammeReviewBalancedCache.new(
          term_id: term.id,
          term_name: term.name,
          term_start: term.start,
          term_finish: term.finish,
          section_id: term.section_id,
          last_used_at: Time.now.utc,
        )
      end

      if cached_term.data[:version] != 1
        # Make the data
        cached_term.get_balanced_term_data(@user, @section)
      end

      term_methods = cached_term.data[:methods]
      term_zones = cached_term.data[:zones]

      # Add term data into totals
      [:number, :time].each do |num_or_time|
        term_methods[:number].each_key do |date_key|
          methods[num_or_time][date_key] = blank_hash_for(METHODS) if methods[num_or_time][date_key].nil?
          term_methods[num_or_time][date_key].each_key do |method|
            methods[num_or_time][date_key][method] += term_methods[num_or_time][date_key][method]
          end
        end
        term_zones[num_or_time].each_key do |date_key|
          zones[num_or_time][date_key] = blank_hash_for(ZONES) if zones[num_or_time][date_key].nil?
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
        zones[:number][date_key] = blank_hash_for(ZONES) if zones[:number][date_key].nil?
        methods[:number][date_key] = blank_hash_for(METHODS) if methods[:number][date_key].nil?
        zones[:time][date_key] = blank_hash_for(ZONES) if zones[:time][date_key].nil?
        methods[:time][date_key] = blank_hash_for(METHODS) if methods[:time][date_key].nil?
      end
    end

    # Update used at
    ProgrammeReviewBalancedCache.where(term_id: terms).update_all(last_used_at: Time.now.utc)

    {
      zones: zones,
      methods: methods,
      zone_labels: ZONES[@section.type].clone,
      method_labels: METHODS[@section.type].clone,
      statistics: {
        earliest_date: earliest,
        latest_date: latest,
        zones: get_balanced_statistics(zones, ZONES),
        methods: get_balanced_statistics(methods, METHODS)
      }
    }
  end


  private

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

  def blank_hash_for(zones_or_methods)
    zones_or_methods[@section.type].each_with_object({}) do |key, hash|
      hash[key.first] = 0
    end
  end
end
