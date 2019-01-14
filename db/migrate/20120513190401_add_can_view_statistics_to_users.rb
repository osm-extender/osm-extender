class AddCanViewStatisticsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :can_view_statistics, :boolean, :default => false
  end
end
