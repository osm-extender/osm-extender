class CreateSharedEventAttendances < ActiveRecord::Migration

  def change
    create_table :shared_event_attendances do |t|
      t.references :shared_event, :null => false
      t.references :user, :null => false
      t.integer :section_id, :null => false
      t.integer :event_id, :null => false

      t.timestamps
    end

    add_index :shared_event_attendances, :shared_event_id
    add_index :shared_event_attendances, :user_id
  end

end
