class CreateSettingValues < ActiveRecord::Migration

  def change
    create_table :setting_values do |t|
      t.string :key
      t.text :value
    end

    add_index :setting_values, :key, :unique => true
  end

end
