class AddCanAdministerSettingsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :can_administer_settings, :boolean, :default => false
  end
end
