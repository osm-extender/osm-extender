class AddCanAdministerDelayedJobToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_administer_delayed_job, :boolean, :default => false
  end
end
