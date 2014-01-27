class RemoveCanAdministerSettingsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :can_administer_settings
  end

  def down
    add_column :users, :can_administer_settings, :boolean, :default => false
  end
end
