class AddCanAdministerAnnouncementsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :can_administer_announcements, :boolean, :default => false
  end
end
