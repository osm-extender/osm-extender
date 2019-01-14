class AddDescriptionToSettingValue < ActiveRecord::Migration[4.2]

  def self.up
    add_column :setting_values, :description, :text, :null=>false, :default=>'Ooops, a description of this setting should appear here'
    change_column :setting_values, :key, :string, :null=>false
  end

  def self.down
    remove_column :setting_values, :description
  end

end
