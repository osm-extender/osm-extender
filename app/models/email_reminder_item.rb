# This class is expected to be inherited from, the inheriting class MUST:
# * provide a get_data method which will return the data to be provided to the email template
# * provide a get_fake_data method which will return a fake version of the data for use in previewing the data without accessing OSM
# * human_name - to return a user friendly name for the class (e.g. Missed Scouts)
# * provide a default_configuration method to return a complete configuration hash with default values
# * provide the following methods unless default_configuration returns an empty hash
#   * configuration_labels - to return a hash (keys are the keys into the configuration hash, values are the labels to display to the user)
#   * configuration_types - to return a hash (keys are the keys used in the above hash, value is the Class that the value should be converted to)
#   * human_configuration - to return a string containing a user friendly version of the configuration (e.g. "From 1 week ago to 3 weeks time")

class EmailReminderItem < ActiveRecord::Base
  attr_accessible :email_reminder, :configuration, :position

  belongs_to :email_reminder

  serialize :configuration, Hash

  validates_presence_of :email_reminder_id
  validates_presence_of :type

  validates_numericality_of :position, :only_integer=>true, :greater_than_or_equal_to=>0

  validate :only_one_of_each_type

  acts_as_list


  def get_data
    raise "This method must be overridden"
  end

  def get_fake_data
    raise "This method must be overridden"
  end

  def human_name
    raise "This method must be overridden"
  end

  def default_configuration
    raise "This method must be overridden"
  end


  def configuration_labels
    if default_configuration.empty?
      return {}
    else
      raise "This method must be overridden"
    end
  end

  def configuration_types
    if default_configuration.empty?
      return {}
    else
      raise "This method must be overridden"
    end
  end

  def human_configuration
    if default_configuration.empty?
      return "There are no settings for this item."
    else
      raise "This method must be overridden"
    end
  end


  def configuration=(config)
    conversion_functions = {
      Fixnum => :to_i,
      Float => :to_f,
      String => :to_s,
      Symbol => :to_sym
    }
    default = default_configuration

    # Ensure only keys in the default_configuration exist in configuration
    config.select {|k,v| default.keys.include?(k) && default[k] != v}

    # Make any type conversions required
    config.each_key do |key|
      conversion_function = conversion_functions[configuration_types[key]]
      unless conversion_function.nil?
        begin
          config[key] = config[key].send(conversion_function)
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
    default = default_configuration
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
