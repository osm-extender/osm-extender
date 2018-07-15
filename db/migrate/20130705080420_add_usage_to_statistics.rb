class AddUsageToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :usage, :text
  end
end
