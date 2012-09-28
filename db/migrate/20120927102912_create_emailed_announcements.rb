class CreateEmailedAnnouncements < ActiveRecord::Migration
  def change
    create_table :emailed_announcements do |t|
      t.references :announcement
      t.references :user

      t.timestamps
    end

    add_index :emailed_announcements, :announcement_id
    add_index :emailed_announcements, :user_id
    add_index :hidden_announcements, [:announcement_id, :user_id], :unique => true
  end
end
