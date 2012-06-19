# This class is expected to be inherited from, the inheriting class MUST:
# * provide a get_data method which will return the data to be provided to the email template
# * provide a labels method to return a hash (keys are the keys into the configuration hash, values are the labels to display to the user)
# * provide a default_configuration method to return a complete configuration hash with default values
# * provide a configuration_types method to return a hash (keys are the keys used in the above hash, value is the Class that the value should be converted to)
# * provide a friendly_name method to return a user friendly name for the class (e.g. Missed Scouts)

class EmailReminderItem < ActiveRecord::Base
  attr_accessible :email_reminder, :configuration

  belongs_to :email_reminder

  serialize :configuration, Hash

  validates_presence_of :email_reminder_id
  validates_presence_of :type

  validate :only_one_of_each_type


  def get_data
    raise "This method must be overridden"
  end

  def labels
    raise "This method must be overridden"
  end

  def default_configuration
    raise "This method must be overridden"
  end

  def configuration_types
    raise "This method must be overridden"
  end

  def friendly_name
    raise "This method must be overridden"
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
        errors.add(:email_reminder, "already has #{an_or_a(friendly_name)} #{friendly_name.downcase} reminder")
      end
    end
  end

  def an_or_a(text)
    %w{a e i o u}.include?(text.first.downcase) ? 'an' : 'a'
  end
end
