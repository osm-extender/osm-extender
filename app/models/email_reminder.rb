class EmailReminder < ActiveRecord::Base
  has_paper_trail
##  has_associated_audits

  belongs_to :user
  has_many :items, -> { order :position }, class_name: EmailReminderItem, dependent: :destroy, inverse_of: :email_reminder
  has_many :shares, class_name: EmailReminderShare, dependent: :destroy, foreign_key: :reminder_id, inverse_of: :reminder

  validates_presence_of :user
  
  validates_presence_of :section_id
  validates_numericality_of :section_id, :only_integer=>true, :greater_than=>0

  validates_presence_of :send_on
  validates_inclusion_of :send_on, :in => 0..6

  validates_presence_of :section_name
  before_validation :set_section_name


  def send_email(options={})
    # :only_to is an array of strings or objects with an :email_address method or nil (send to everyone).
    # :except_to is an array of strings or objects with an :email_address method or nil (send to everyone).
    # :skip_subscribed_check if true then the email will be sent even if the subscription state is not :subscribed

    # A single item may be passed in on it's own.
    # It will become an array of strings containing lowercase email addresses
    [:only_to, :except_to].each do |option|
      unless options[option].nil?
        options[option] = [ options[option] ] unless options[option].is_a?(Array)
        options[option].each_with_index do |item, index|
          options[option][index] = (item.is_a?(String) ? item : item.email_address).downcase
        end
      end
    end

    only_to = options[:only_to]
    except_to = options[:except_to] || []
    send_to = []
    get_addresses.each do |address|
      email = address[:email_address].downcase
      if (only_to.nil? || only_to.include?(email))  &&  !except_to.include?(email)
        send_to.push(address)
      end
    end

    if user.connected_to_osm?
      section = Osm::Section.get(user.osm_api, section_id)
      unless section.nil?
        # We now know that the user can access this section
        begin
          data = get_data
          send_to.each do |person|
            if person[:share].nil? || (person[:share].subscribed? || options[:skip_subscribed_check])
              ReminderMailer.reminder_email(self, data, person).deliver
            end
          end
        rescue Exception => exception
          ReminderMailer.failed(self).deliver
          NotifierMailer.reminder_failed(self, exception).deliver
        end
      end
    end
  end

  def has_an_item_of_type?(type)
    hits = EmailReminderItem.where(['email_reminder_id = ? AND type = ?', self.id, type]).count
    return (hits > 0)
  end

  def get_data
    build_data :get_data
  end

  def get_fake_data
    build_data :get_fake_data
  end


  private
  def build_data(data_method)
    display_items = []
    error_items = []

    items.each do |item|
      begin
        data = item.send(data_method)
        data = nil if (data.blank? || data.empty?)
        display_items.push ({ :item => item, :data => data })
      rescue Osm::Error => exception
        error_items.push({ :item => item, :exception => exception })
      end
    end

    return {
      :display_items => display_items,
      :error_items => error_items
    }
  end

  def set_section_name
    section = Osm::Section.get(user.osm_api, read_attribute(:section_id))
    write_attribute :section_name, "#{section.name} (#{section.group_name})"
  end

  def get_addresses
    emails = [{ :name=>user.name, :email_address=>user.email_address }]
    emails += shares.collect{ |share| {:name=>share.name, :email_address=>share.email_address, :share=>share } }
  end

end
