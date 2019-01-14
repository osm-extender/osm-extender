class DropUsageLogs < ActiveRecord::Migration[4.2]
  def change
    drop_table :usage_logs
    remove_column :statistics, :usage
  end
end
