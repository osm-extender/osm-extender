class CreateSharedEventFields < ActiveRecord::Migration[4.2]

  def change
    create_table :shared_event_fields do |t|
      t.references :shared_event, :null => false
      t.string :name, :null => false

      t.timestamps
    end

    add_index :shared_event_fields, :shared_event_id
  end

end
