class AddDescriptionToSettingValue < ActiveRecord::Migration

  def self.up
    add_column :setting_values, :description, :text, :null=>false
    change_column :setting_values, :key, :string, :null=>false
  end

  def self.down
    remove_column :setting_values, :description
  end

end
