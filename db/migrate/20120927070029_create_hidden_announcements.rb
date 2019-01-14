class CreateHiddenAnnouncements < ActiveRecord::Migration[4.2]
  def change
    create_table :hidden_announcements do |t|
      t.references :user, :null => false
      t.references :announcement, :null => false

      t.timestamps
    end

    add_index :hidden_announcements, :user_id
    add_index :hidden_announcements, :announcement_id
    add_index :hidden_announcements, [:user_id, :announcement_id], :unique => true
  end
end
