class AddCanBecomeOtherUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_become_other_user, :boolean, :default => false
  end
end
