class CreateSharedEventFieldData < ActiveRecord::Migration[4.2]

  def change
    create_table :shared_event_field_data do |t|
      t.references :shared_event_field, :null => false
      t.references :shared_event_attendance, :null => false
      t.string :source_type, :null => false
      t.integer :source_id
      t.string :source_field, :null => false

      t.timestamps
    end

    add_index :shared_event_field_data, :shared_event_field_id
    add_index :shared_event_field_data, :shared_event_attendance_id
  end

end
