class AddEmailReminderSharesByDayToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :email_reminder_shares_by_day, :text
  end
end
