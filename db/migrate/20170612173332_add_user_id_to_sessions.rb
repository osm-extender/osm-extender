class AddUserIdToSessions < ActiveRecord::Migration
  def change
    change_table :sessions do |t|
      t.references :user, index: true
    end
  end
end
