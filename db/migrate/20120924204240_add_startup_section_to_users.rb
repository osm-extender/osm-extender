class AddStartupSectionToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :startup_section, :integer, :default => 0, :null => false
  end
end
