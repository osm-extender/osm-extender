module MigrationValidators
  module Adapters
    class Sqlite < MigrationValidators::Adapters::Base
      def name
        "SQLite Migration Validators Adapter"
      end

      define_base_syntax
      define_base_validators
      define_base_containers

      container :insert_trigger do
        operation :db_value do |value|
          case value.class.name
            when "String" then "'#{value}'"
            when "Date" then "date('#{value.strftime('%Y-%m-%d')}')"
            when "DateTime" then "datetime('#{value.strftime('%Y-%m-%d %H:%M:%S')}')"
            when "Time" then "datetime('#{value.strftime('%Y-%m-%d %H:%M:%S')}')"
            else value.to_s
          end
        end

        operation :bind_to_error do |stmt, error_message|
          "SELECT RAISE(ABORT, '#{error_message}') 
            WHERE NOT(#{stmt})"
        end
      end

      container :update_trigger do
        operation :db_value do |value|
          case value.class.name
            when "String" then "'#{value}'"
            when "Date" then "date('#{value.strftime('%Y-%m-%d')}')"
            when "DateTime" then "datetime('#{value.strftime('%Y-%m-%d %H:%M:%S')}')"
            when "Time" then "datetime('#{value.strftime('%Y-%m-%d %H:%M:%S')}')"
            else value.to_s
          end
        end

        operation :bind_to_error do |stmt, error_message|
          "SELECT RAISE(ABORT, '#{error_message}')
            WHERE NOT(#{stmt})"
        end
      end


      route :presence, :trigger, :default => true do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end

      route :inclusion, :trigger, :default => true do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end

      route :exclusion, :trigger, :default => true do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end

      route :length, :trigger, :default => true do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end

      route :uniqueness, :trigger do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end
    end

    MigrationValidators.register_adapter! "sqlite3", Sqlite
  end
end
