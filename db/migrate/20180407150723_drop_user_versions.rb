class UserVersion < ActiveRecord::Base
end


class DropUserVersions < ActiveRecord::Migration
  def up
    UserVersion.transaction do
      UserVersion.find_in_batches do |records|
        records.each do |record|
          PaperTrail::Version.create record.attributes.except('id')
        end # record
      end # records
    drop_table :user_versions
    end # transaction
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
