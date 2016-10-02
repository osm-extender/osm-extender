# This class is expected to be inherited from.
# The inheriting class MUST provide the following methods:
# * self.required_permissions - permission arguments for user.has_osm_permission?, eg [:read, :register] [[:read, :register], [:write, :badges]]
# * self.human_name - to return a user friendly name for the class (e.g. Missed Scouts)
# * self.default_configuration - to return a complete configuration hash with default values
# * Unless default_configuration returns an empty hash
#   * self.configuration_labels - to return a hash (keys are the keys into the configuration hash, values are the labels to display to the user)
#   * self.configuration_types - to return a hash (keys are the keys used in the above hash, value is the Class that the value should be converted to)
#   * human_configuration - to return a string containing a user friendly version of the configuration (e.g. "From 1 week ago to 3 weeks time")
# * (private) perform_task(user=self.user) - to perform the task, returns a Hash with the keys - :success (boolean), :log_lines/:errors (array of [string/array of string]).
# The inheriting class MUST provide the following constants:
# * ALLOWED_SECTIONS - an array of symbols representing the allowed section types for this task

class AutomationTask < ActiveRecord::Base
  has_paper_trail

  belongs_to :user

  serialize :configuration, Hash

  before_validation :set_section_name

  validates_presence_of :user_id
  validates_presence_of :type
  validates_presence_of :section_id
  validates_presence_of :section_name

  validate :only_one_of_each_type


  def do_task(user=self.user)
    unless user.connected_to_osm?
      return {success: false, errors: ["#{user.name} hasn't connected their account to OSM yet."]}
    end
    unless has_permissions?(user)
      return {success: false, errors: ["#{user.name} doesn't have the correct OSM permissions."]}
    end

    perform_task(user)
  end


  def self.human_name
    fail "The self.human_name method must be overridden"
  end
  def human_name
    self.class.human_name
  end

  def self.default_configuration
    {}
  end

  def self.configuration_labels
    if default_configuration.empty?
      return {}
    else
      fail "The self.configuration_labels method must be overridden"
    end
  end

  def self.configuration_types
    if default_configuration.empty?
      return {}
    else
      fail "The self.configuration_types method must be overridden"
    end
  end

  def self.required_permissions
    fail "The self.required_permissions method must be overridden"
  end


  def human_configuration
    if self.class.default_configuration.empty?
      return "There are no settings for this item."
    else
      fail "The human_configuration method must be overridden"
    end
  end

  def configuration=(config)
    conversion_functions = {
      :integer => Proc.new { |value| value.to_i },
      :positive_integer => Proc.new { |value| value.to_i.magnitude },
      :boolean => Proc.new { |value| ['0', 0].include?(value) ? false : !!value },
      :string => Proc.new { |value| value.to_s },
      :symbol => Proc.new { |value| value.to_sym },
    }
    default = self.class.default_configuration

    # Ensure only keys in the default_configuration exist in configuration
    config.select! {|k,v| default.has_key?(k) && default[k] != v}

    # Make any type conversions required
    config.each_key do |key|
      conversion_function = conversion_functions[self.class.configuration_types[key]]
      unless conversion_function.nil?
        begin
          config[key] = conversion_function.call(config[key])
          if config[key].nil?
            errors.add(key, "is invalid")
          end
        rescue
          errors.add(key, "is invalid")
        end
      end
    end

    # Save adjusted hash
    write_attribute(:configuration, default.merge(config))
  end

  def configuration
    default = self.class.default_configuration
    config = read_attribute(:configuration)
    config.select {|k,v| default.has_key?(k)}
    return default.merge(config)
  end


  def self.unused_items(user, section)
    section = Osm::Section.get(User.first.osm_api, section.to_i) unless section.is_a?(Osm::Section)
    Rails.application.eager_load! unless Rails.application.config.cache_classes  # cache_clases is off in dev and on in prod

    items = Module.constants.map{ |i| i=eval(i.to_s) }
    items.select!{ |i| !i.nil? && i.is_a?(Class) && i.superclass.eql?(self) }
    items.select!{ |i| where(['section_id = ? AND type = ?', section.to_i, i]).count.eql?(0) }
    items.select!{ |i| i::ALLOWED_SECTIONS.include?(section.type) }
    items.map!{ |i| {type: i, has_permissions: i.has_permissions?(user, section)} }
    items
  end


  def self.has_permissions?(user, section)
    required_permissions.each do |rp|
      return false unless user.has_osm_permission?(section, *rp)
    end
    return true
  end
  def has_permissions?(user=self.user)
    self.class.has_permissions?(user, self.section_id)
  end


  private
  def set_section_name
    return unless user.try('connected_to_osm?')
    section = Osm::Section.get(user.osm_api, read_attribute(:section_id))
    write_attribute :section_name, "#{section.name} (#{section.group_name})"
  end

  def only_one_of_each_type
    self.class.where(['section_id = ? AND type = ?', section_id, self.type]).each do |item|
      if item != self
        errors.add(:automation_task_item, "already has #{an_or_a(human_name)} #{human_name.downcase} task")
      end
    end
  end

  def an_or_a(text)
    %w{a e i o u}.include?(text.first.downcase) ? 'an' : 'a'
  end

  def perform_task(user=self.user)
    fail "The perform_task method must be overridden"
  end

end
