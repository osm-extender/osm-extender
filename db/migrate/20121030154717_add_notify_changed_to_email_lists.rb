class AddNotifyChangedToEmailLists < ActiveRecord::Migration
  def change
    add_column :email_lists, :notify_changed, :boolean, :default => false, :null => false
    add_column :email_lists, :last_hash_of_addresses, :string, :limit => 64, :default => '', :null => false

    add_index :email_lists, :notify_changed
  end
end
