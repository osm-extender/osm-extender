class DropMigrationValidators < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.table_exists? :migration_validators
      drop_table :migration_validators
    end
  end

  def self.down
    fail ActiveRecord::IrreversibleMigration
  end
end
