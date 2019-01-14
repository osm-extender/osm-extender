class AddEmailReminderSharesByDayToStatistics < ActiveRecord::Migration[4.2]
  def change
    add_column :statistics, :email_reminder_shares_by_day, :text
  end
end
