class AddPositionToEmailReminderItems < ActiveRecord::Migration
  def change
    add_column :email_reminder_items, :position, :integer, :default => 0, :null => false
  end
end
