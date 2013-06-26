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


  def self.sections
    section_ids_seen = []
    section_types = {:beavers=>0, :cubs=>0, :scouts=>0, :explorers=>0, :adults=>0, :waiting=>0}
    subscription_levels = {1=>0, 2=>0, 3=>0}
    total = 0

    User.where("osm_userid IS NOT NULL").each do |user|
      Osm::Section.get_all(user.osm_api).each do |section|
        unless section_ids_seen.include?(section.id)
          section_ids_seen.push section.id
          total += 1
          section_types[section.type] += 1
          subscription_levels[section.subscription_level] += 1 if Constants::YOUTH_SECTIONS.include?(section.type)
        end
      end
    end

    return {
      :section_types => section_types,
      :subscription_levels => subscription_levels,
      :total => total,
    }
  end

end
