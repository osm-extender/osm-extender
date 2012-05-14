class AddCanViewStatisticsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_view_statistics, :boolean, :default => false
  end
end
