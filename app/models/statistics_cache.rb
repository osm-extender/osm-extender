class StatisticsCache < ActiveRecord::Base
  attr_accessible :date, :users, :email_reminders, :email_reminders_by_day, :email_reminders_by_type

  serialize :email_reminders_by_day, Array
  serialize :email_reminders_by_type, Hash

  validates_presence_of :date
  validates_uniqueness_of :date

  validates_presence_of :email_reminders
  validates_numericality_of :email_reminders, :only_integer=>true, :greater_than=>0

  validates_presence_of :users
  validates_numericality_of :users, :only_integer=>true, :greater_than=>0



  def self.create_or_retrieve_for_date(date)
    exists = find_by_date(date)
    return exists if exists

    data = Hash.new
    data[:date] = date


    # Users
    data[:users] = User.where(['created_at < ?', date + 1]).count


    # Email Reminders
    data[:email_reminders] = EmailReminder.where(['created_at < ?', date + 1]).count

    by_day = Array.new(7, 0)
    EmailReminder.where(['created_at < ?', date + 1]).group(:send_on).count.each do |day, count|
      by_day[day] = count
    end
    data[:email_reminders_by_day] = by_day

    data[:email_reminders_by_type] = EmailReminderItem.where(['created_at < ?', date + 1]).group(:type).count

    create(data)
  end

end
