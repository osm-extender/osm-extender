class AddClosingUpdatesToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :closing_updates, :boolean
  end
end
