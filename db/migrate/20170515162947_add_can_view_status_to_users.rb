class AddCanViewStatusToUsers < ActiveRecord::Migration

  def up
    add_column :users, :can_view_status, :boolean, :default => false

    User.where(can_view_statistics: true).each do |user|
      user.update can_view_status: true
    end
  end

  def down
    remove_column :users, :can_view_status
  end

end
