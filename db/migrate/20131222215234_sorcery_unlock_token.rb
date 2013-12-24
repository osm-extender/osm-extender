class SorceryUnlockToken < ActiveRecord::Migration
  def self.up
    add_column :users, :unlock_token, :string, :default => nil
    add_index :users, :unlock_token
  end

  def self.down
    remove_index :users, :unlock_token
    remove_column :users, :unlock_token
  end
end
