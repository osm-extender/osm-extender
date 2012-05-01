class EmailReminder < ActiveRecord::Base
  belongs_to :user
  has_many :items, :class_name=>'EmailReminderItem', :dependent=>:destroy

  validates_presence_of :user
  
  validates_presence_of :section_id
  validates_numericality_of :section_id, :only_integer=>true, :greater_than=>0

  validates_presence_of :send_on
  validates_inclusion_of :send_on, :in => 0..6


  def send_email
    if user.connected_to_osm?
      section = user.osm_api.get_section(section_id)
      unless section.nil?
        # We now know that the user can access this section
        begin
          ReminderMailer.reminder_email(user, section.role, get_data).deliver
        rescue Exception => exception
          ReminderMailer.failed(self, section.role).deliver
          NotifierMailer.reminder_failed(self, exception).deliver unless Settings.read('notifier mailer - send failed reminder to').blank?
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
    data = {}
    config = {}
    items.each do |item|
      key = item.type.to_sym
      data[key] = item.send(data_method)
      config[key] = item.configuration
    end
    return {:data=>data, :config=>config}
  end

end
