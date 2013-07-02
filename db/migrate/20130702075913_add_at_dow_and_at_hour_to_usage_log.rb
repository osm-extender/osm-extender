class AddAtDowAndAtHourToUsageLog < ActiveRecord::Migration

  class UsageLog < ActiveRecord::Base
    belongs_to :user
    serialize :extra_details, Hash
    validates_presence_of :user
    validates_presence_of :controller
    validates_presence_of :action
    validates_presence_of :at
    validates_presence_of :at_hour
    validates_presence_of :at_day_of_week
  end

  def up
    # Add columns
    add_column :usage_logs, :at_day_of_week, :integer
    add_column :usage_logs, :at_hour, :integer

    # Populate columns (deleting the ones which can't be populated)
    say "Calculating hour and day of week for existing records"
    UsageLog.all.each do |record|
      record.at_hour = record.at.utc.hour
      record.at_day_of_week = record.at.utc.wday
      record.save
    end

    # Add in null constraints
    change_column :usage_logs, :at_day_of_week, :integer, :null => false
    change_column :usage_logs, :at_hour, :integer, :null => false
  end

  def down
    remove_column :usage_logs, :at_day_of_week
    remove_column :usage_logs, :at_hour
  end

end
