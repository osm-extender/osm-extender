class AddSectionIdIndexToEmailLists < ActiveRecord::Migration[4.2]
  def change
    add_index :email_lists, :section_id
  end
end
