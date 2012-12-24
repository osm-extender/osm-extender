class CreateSharedEvents < ActiveRecord::Migration

  def change
    create_table :shared_events do |t|
      t.string :name, :null => false
      t.date :start_date
      t.string :start_time
      t.date :finish_date
      t.string :finish_time
      t.string :cost
      t.string :location
      t.text :notes
      t.references :user, :null => false

      t.timestamps
    end

    add_index :shared_events, :user_id
  end

end
