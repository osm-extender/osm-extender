class AddUsageToStatistics < ActiveRecord::Migration[4.2]
  def change
    add_column :statistics, :usage, :text
  end
end
