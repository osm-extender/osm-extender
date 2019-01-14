class CreateUserVersions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :user_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :user_versions, [:item_type, :item_id]
  end

  def self.down
    remove_index :user_versions, [:item_type, :item_id]
    drop_table :user_versions
  end
end
