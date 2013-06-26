class Statistics < ActiveRecord::Base
  attr_accessible :date, :users, :email_reminders, :email_reminders_by_day, :email_reminder_shares_by_day, :email_reminders_by_type

  serialize :email_reminders_by_day, Array
  serialize :email_reminder_shares_by_day, Array
  serialize :email_reminders_by_type, Hash

  validates_presence_of :date
  validates_uniqueness_of :date

  validates_presence_of :email_reminders
  validates_numericality_of :email_reminders, :only_integer=>true, :greater_than_or_equal_to=>0

  validates_presence_of :users
  validates_numericality_of :users, :only_integer=>true, :greater_than_or_equal_to=>0



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
    shared_by_day = Array.new(7)
    (0..6).each do |i|
      shared_by_day[i] = {"pending"=>0, "subscribed"=>0, "unsubscribed"=>0}
    end
    EmailReminder.where(['created_at < ?', date + 1]).each do |reminder|
      by_day[reminder.send_on] += 1
      reminder.shares.where(['created_at < ?', date + 1]).group(:state).count.each do |state, count|
        shared_by_day[reminder.send_on][state] += count
      end
    end
    data[:email_reminders_by_day] = by_day
    data[:email_reminder_shares_by_day] = shared_by_day

    data[:email_reminders_by_type] = EmailReminderItem.where(['created_at < ?', date + 1]).group(:type).count

    record = (date < Date.today) ? create(data) : new(data) # Create (and save) only if date is in the past
    record.attributes.deep_dup
  end

end
