class ProgrammeCreate

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user, :section, :programme_interval, :evening_title
  attr_reader :programme_start, :programme_end, :evening_start, :evening_end

  validates_presence_of :user, :section, :programme_start, :programme_interval, :programme_end, :evening_start, :evening_end, :evening_title

  validates_numericality_of :programme_interval, :only_integer=>true, :greater_than=>0

  validates :evening_start, :time_24h_format => true
  validates :evening_end, :time_24h_format => true

  validates :programme_start, :date_format => true
  validates :programme_end, :date_format => true

  validate :dates_in_right_order, :if=>Proc.new { |record| (record.programme_start && record.programme_end) }
  validate :times_in_right_order, :if=>Proc.new { |record| (record.evening_start && record.evening_end) }
  validate :terms_exist, :if=>Proc.new { |record| (record.programme_start && record.programme_end) }


  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    @programme_interval ||= 7
  end

  def create_programme
    if valid?
      # Populate programme
      meetings = Array.new
      dates = (programme_start.to_date..programme_end.to_date).step(programme_interval.to_i)
      dates.each do |day|
        meetings.push day
        user.osm_api.create_evening(section.id, day)
      end

      # Find what we just added
      updated = 0
      (user.osm_api.get_terms).each do |term|
        unless ((term.start > programme_end) || (term.end < programme_start)) # Term may contain meetings
          (user.osm_api.get_programme(term.section_id, term.id)).each do |programme|
            if (meetings.include?(programme.meeting_date) && programme.title.eql?('Unnamed meeting') &&
                programme.notes_for_parents.blank? && programme.games.blank? &&
                programme.pre_notes.blank? && programme.post_notes.blank? && programme.leaders.blank? &&
                programme.activities.eql?([]) && programme.start_time.nil? && programme.end_time.nil?
            ) # This is probably something we just added
              programme.title = evening_title
              programme.start_time = evening_start
              programme.end_time = evening_end
              result = user.osm_api.update_evening(programme)
              updated += 1
            end
          end
        end
      end
      return updated == meetings.size
    end
    return nil
  end


  # Custom setters for dates
  [:programme_start, :programme_end].each do |attribute|
    define_method "#{attribute}=" do |value|
      begin
        value = Date.strptime(value, '%Y-%m-%d')
      rescue
        value = nil
      end
      instance_variable_set("@#{attribute}", value)
    end
  end

  # Custom setters for times
  [:evening_start, :evening_end].each do |attribute|
    define_method "#{attribute}=" do |value|
      value = /\A(?:[0-1][0-9]|2[0-3]):[0-5][0-9]\Z/.match(value) ? value : nil
      instance_variable_set("@#{attribute}", value)
    end
  end


  def persisted?
    false
  end


  private
  def dates_in_right_order
    errors.add(:programme_end, "can't be before programme start") if programme_end < programme_start
  end
  
  def times_in_right_order
    errors.add(:evening_end, "can't be before evening start") if evening_end < evening_start
  end

  def terms_exist
    earliest = nil
    latest = nil
    (user.osm_api.get_terms).sort.each do |term|
      unless term.end < programme_start || term.start > programme_end
        earliest = earliest || term.start
        latest = latest || term.end
        earliest = (term.start < earliest) ? term.start : earliest
        latest = (term.end > latest) ? term.end : latest
      end
    end
    errors.add(:programme_start, "can't be before your terms (add/edit them in OSM)") if (earliest.nil? || programme_start < earliest)
    errors.add(:programme_end, "can't be after your terms (add/edit them in OSM)") if (latest.nil? || programme_end > latest)
  end

end