class RemoveSettingValues < ActiveRecord::Migration

  def self.up
    drop_table :setting_values
  end

  def self.down
    create_table :setting_values do |t|
      t.string :key, :null => false
      t.text :value
      t.string :description, :null => false, :default=>'Ooops, a description of this setting should appear here'
    end

    add_index :setting_values, :key, :unique => true
  end

end
