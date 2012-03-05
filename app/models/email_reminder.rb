class EmailReminder < ActiveRecord::Base
  belongs_to :user
  has_many :items, :class_name=>'EmailReminderItem', :dependent=>:destroy

  validates_presence_of :user
  
  validates_presence_of :section_id
  validates_numericality_of :section_id, :only_integer=>true, :greater_than=>0
  
  validates_presence_of :send_on
  validates_inclusion_of :send_on, :in => 0..6


  def send_email
    begin
      data = {}
      configuration = {}
      items.each do |item|
        key = item.type.to_sym
        data[key] = item.get_data
        configuration[key] = item.configuration
      end
      ReminderMailer.reminder_email(user, data, configuration).deliver
    rescue Exception => exception
      ReminderMailer.failed(self).deliver
      NotifierMailer.reminder_failed(self, exception).deliver
    end
  end

  def has_an_item_of_type?(type)
    hits = EmailReminderItem.where(['email_reminder_id = ? AND type = ?', self.id, type]).count
    return (hits > 0)
  end
end
