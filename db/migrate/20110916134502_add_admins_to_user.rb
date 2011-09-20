class AddAdminsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :admin_system, :boolean, :default=>false
    add_column :users, :admin_sms, :boolean, :default=>false
  end

  def self.down
    remove_column :users, :admin_system
    remove_column :users, :admin_sms
  end
end
