class CreateAnnouncements < ActiveRecord::Migration[4.2]
  def change
    create_table :announcements do |t|
      t.text :message, :null => false
      t.datetime :start, :null => false
      t.datetime :finish, :null => false
      t.boolean :public, :null => false, :default => false
      t.boolean :prevent_hiding, :null => false, :default => false
      t.timestamp :emailed_at, :null => true

      t.timestamps
    end
  end
end
