class AddSectionIdIndexToEmailLists < ActiveRecord::Migration
  def change
    add_index :email_lists, :section_id
  end
end
