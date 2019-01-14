class AddUserIdToSessions < ActiveRecord::Migration[4.2]
  def change
    change_table :sessions do |t|
      t.references :user, index: true
    end
  end
end
