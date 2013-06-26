# This class is expected to be inherited from.
# The inheriting class MUST provide the following methods:
# * get_data method - to return the data to be provided to the email template
# * get_fake_data - to will return a fake version of the data for use in previewing the data without accessing OSM
# * self.human_name - to return a user friendly name for the class (e.g. Missed Scouts)
# * self.default_configuration - to return a complete configuration hash with default values
# * Unless default_configuration returns an empty hash
#   * self.configuration_labels - to return a hash (keys are the keys into the configuration hash, values are the labels to display to the user)
#   * self.configuration_types - to return a hash (keys are the keys used in the above hash, value is the Class that the value should be converted to)
#   * human_configuration - to return a string containing a user friendly version of the configuration (e.g. "From 1 week ago to 3 weeks time")

class EmailReminderItem < ActiveRecord::Base
  audited :associated_with => :email_reminder

  attr_accessible :email_reminder, :configuration, :position

  belongs_to :email_reminder

  serialize :configuration, Hash

  validates_presence_of :email_reminder_id
  validates_presence_of :type

  validates_numericality_of :position, :only_integer=>true, :greater_than_or_equal_to=>0

  validate :only_one_of_each_type

  acts_as_list


  def get_data
    raise "The get_data method must be overridden"
  end

  def get_fake_data
    raise "The get_fake_data method must be overridden"
  end


  def self.human_name
    raise "The self.human_name method must be overridden"
  end
  def human_name
    self.class.human_name
  end

  def self.default_configuration
    raise "The self.default_configuration method must be overridden"
  end

  def self.configuration_labels
    if self.default_configuration.empty?
      return {}
    else
      raise "The self.configuration_labels method must be overridden"
    end
  end

  def self.configuration_types
    if self.default_configuration.empty?
      return {}
    else
      raise "This method must be overridden"
    end
  end


  def human_configuration
    if self.class.default_configuration.empty?
      return "There are no settings for this item."
    else
      raise "The human_configuration method must be overridden"
    end
  end


  def configuration=(config)
    conversion_functions = {
      :integer => Proc.new { |value| value.to_i },
      :positive_integer => Proc.new { |value| value.to_i.magnitude },
      :boolean => Proc.new { |value| value.is_a?(String) ? value.eql?('1') : !!value },
      :string => Proc.new { |value| value.to_s },
      :symbol => Proc.new { |value| value.to_sym },
    }
    default = self.class.default_configuration

    # Ensure only keys in the default_configuration exist in configuration
    config.select {|k,v| default.keys.include?(k) && default[k] != v}

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
    config.select {|k,v| default.keys.include?(k)}
    return default.merge(config)
  end


  protected
  def user
    email_reminder.user
  end

  def section_id
    email_reminder.section_id
  end


  private
  def only_one_of_each_type
    email_reminder.items.each do |item|
      if (item.type == self.type) && (item != self)
        errors.add(:email_reminder, "already has #{an_or_a(human_name)} #{human_name.downcase} reminder")
      end
    end
  end

  def an_or_a(text)
    %w{a e i o u}.include?(text.first.downcase) ? 'an' : 'a'
  end
end
