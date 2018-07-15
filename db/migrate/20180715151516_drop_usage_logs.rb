class DropUsageLogs < ActiveRecord::Migration
  def change
    drop_table :usage_logs
    remove_column :statistics, :usage
  end
end
