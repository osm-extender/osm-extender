class AddCanAdministerUsersToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :can_administer_users, :boolean, :default => false
  end
end
