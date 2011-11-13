class AddCanAdministerUsersToUser < ActiveRecord::Migration
  def change
    add_column :users, :can_administer_users, :boolean, :default => false
  end
end
