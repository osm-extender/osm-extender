class RenameStatisticsCachesToStatistics < ActiveRecord::Migration[4.2]
  def change
    rename_table :statistics_caches, :statistics
  end
end
