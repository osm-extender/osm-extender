class AddCanBecomeOtherUserToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :can_become_other_user, :boolean, :default => false
  end
end
