class AddCanAdministerAnnouncementsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_administer_announcements, :boolean, :default => false
  end
end
