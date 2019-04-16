class ProgrammeReviewBalancedCache < ApplicationRecord

  serialize :data, Hash

  validates_presence_of :term_id
  validates_presence_of :term_name
  validates_presence_of :term_start
  validates_presence_of :term_finish
  validates_presence_of :section_id
  validates_presence_of :data
  validates_presence_of :last_used_at

  scope :for_section, ->(section) { where section_id: section.to_i }

  def get_balanced_term_data(user, section=Osm::Section.get(user.osm_api, section_id))
    zones = {:number => {}, :time => {}}
    methods = {:number => {}, :time => {}}

    Osm::Meeting.get_for_section(user.osm_api, section_id, term_id, {:no_cache => true}).each do |programme|
      date_key = programme.date.strftime('%Y_%m')
      zones[:number][date_key] = blank_hash_for(ProgrammeReview::ZONES[section.type]) if zones[:number][date_key].nil?
      zones[:time][date_key] = blank_hash_for(ProgrammeReview::ZONES[section.type]) if zones[:time][date_key].nil?
      methods[:number][date_key] = blank_hash_for(ProgrammeReview::METHODS[section.type]) if methods[:number][date_key].nil?
      methods[:time][date_key] = blank_hash_for(ProgrammeReview::METHODS[section.type]) if methods[:time][date_key].nil?

      programme.activities.each do |activity|
        activity_details = Osm::Activity.get(user.osm_api, activity.activity_id, nil, {:no_cache => true})
        unless activity_details.nil?
          tags_in_array(activity_details.tags, ProgrammeReview::ZONES[section.type]).each do |tag|
            zone_or_method = tag[0]
            zones[:number][date_key][zone_or_method] += 1
            zones[:time][date_key][zone_or_method] += activity_details.running_time
          end
          tags_in_array(activity_details.tags, ProgrammeReview::METHODS[section.type]).each do |tag|
            zone_or_method = tag[0]
            methods[:number][date_key][zone_or_method] += 1
            methods[:time][date_key][zone_or_method] += activity_details.running_time
          end
        end
      end
    end

    self.data = {
      version: 1,
      zones: zones,
      methods: methods
    }
    last_used_at = Time.now.utc
    save! if term_finish < Date.today

    data
  end

  private

  def blank_hash_for(zones_or_methods)
    zones_or_methods.each_with_object({}) do |key, hash|
      hash[key.first] = 0
    end
  end

  def tags_in_array(tags, array)
    array.each_with_object([]) do |method_or_zone, ret|
      tags.each do |tag|
        ret.push method_or_zone if similar?(method_or_zone, tag)
      end
    end
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

    if a.is_a?(String) && b.is_a?(String)
      a = a.downcase.gsub(/[^a-z0-9]/, '')
      b = b.downcase.gsub(/[^a-z0-9]/, '')
      return a.eql?(b)
    end

    false
  end
end
