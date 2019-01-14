class AddCustomSizesToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :custom_row_height, :integer, :default => 0
    add_column :users, :custom_text_size, :integer, :default => 0
  end
end
