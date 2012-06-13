class RenameStatisticsCachesToStatistics < ActiveRecord::Migration
  def change
    rename_table :statistics_caches, :statistics
  end
end
