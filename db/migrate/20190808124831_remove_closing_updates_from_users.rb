class RemoveClosingUpdatesFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :closing_updates, :boolean
  end
end
