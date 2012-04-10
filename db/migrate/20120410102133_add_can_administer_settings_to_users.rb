class AddCanAdministerSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_administer_settings, :boolean, :default => false
  end
end
