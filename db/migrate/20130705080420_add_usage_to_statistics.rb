class AddUsageToStatistics < ActiveRecord::Migration

  class Statistics < ActiveRecord::Base
    serialize :email_reminders_by_day, Array
    serialize :email_reminder_shares_by_day, Array
    serialize :email_reminders_by_type, Hash
    serialize :usage, Hash  
    validates_presence_of :date
    validates_uniqueness_of :date
    validates_presence_of :email_reminders
    validates_numericality_of :email_reminders, :only_integer=>true, :greater_than_or_equal_to=>0
    validates_presence_of :users
    validates_numericality_of :users, :only_integer=>true, :greater_than_or_equal_to=>0
  end

  def up
    add_column :statistics, :usage, :text

    say "Generating usage statistics from usage log"
    earliest = UsageLog.minimum(:at)
    if earliest
      Statistics.where(['date >= ?', earliest.to_date]).each do |statistic|
        nonunique = {}
        unique_usersection = {}
        unique_all = {}
        UsageLog.where(['DATE(at) = ?', statistic.date]).
        group(:controller, :action).count.each do |(controller, action), count|
          key = "#{controller}|#{action}"
          nonunique[key] ||= 0
          nonunique[key] += count
        end
        UsageLog.where(['DATE(at) = ?', statistic.date]).
        group(:controller, :action, :user_id, :section_id).count.each do |(controller, action), count|
          key = "#{controller}|#{action}"
          unique_usersection[key] ||= 0
          unique_usersection[key] += 1
        end
        UsageLog.where(['DATE(at) = ?', statistic.date]).
        group(:controller, :action, :user_id, :section_id, :extra_details).count.each do |(controller, action), count|
          key = "#{controller}|#{action}"
          unique_all[key] ||= 0
          unique_all[key] += 1
        end
  
        statistic.usage = {
          'unique_all' => unique_all,
          'unique_usersection' => unique_usersection,
          'nonunique' => nonunique,
        }
        statistic.save!
      end
    end
  end

  def down
    remove_column :statistics, :usage
  end

end
