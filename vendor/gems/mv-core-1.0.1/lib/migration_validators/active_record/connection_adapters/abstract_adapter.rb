module MigrationValidators
  module ActiveRecord
    module ConnectionAdapters 
      module AbstractAdapter 
        extend ActiveSupport::Concern

        included do
          class_eval do
            alias_method_chain :initialize_schema_migrations_table, :validators
          end
        end

        def initialize_migration_validators_table
          migrations_table = MigrationValidators.migration_validators_table_name

          unless table_exists?(migrations_table)
            create_table migrations_table do |t|
              t.string :table_name, :null => false, :limit => 255
              t.string :column_name, :null => true, :limit => 255
              t.string :validator_name, :null => false, :limit => 255
              t.text :options#, default: {}.to_yaml
              t.text :constraints#, default: [].to_yaml
            end 

            add_index migrations_table, :table_name
            add_index migrations_table, [:table_name, :column_name], :name => 'mg_vld_tbl_clm'
            add_index migrations_table, [:table_name, :column_name, :validator_name], :name => 'mg_vld_tbl_clm_vldn', :unique => true
          end
        end

        def initialize_schema_migrations_table_with_validators
          initialize_schema_migrations_table_without_validators
          initialize_migration_validators_table
        end
      end
    end
  end
end
