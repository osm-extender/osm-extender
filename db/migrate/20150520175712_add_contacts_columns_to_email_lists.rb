class AddContactsColumnsToEmailLists < ActiveRecord::Migration
  def change
    # Values:
    #   0 - None
    #   1 - Only Email 1
    #   2 - Only Email 2
    #   3 - All Emails
    #   4 - Enabled Emails (not applicable to emergency contact)
    add_column :email_lists, :contact_member, :integer, :default => 0, :null => false
    add_column :email_lists, :contact_primary, :integer, :default => 0, :null => false
    add_column :email_lists, :contact_secondary, :integer, :default => 0, :null => false
    add_column :email_lists, :contact_emergency, :integer, :default => 0, :null => false
  end
end
