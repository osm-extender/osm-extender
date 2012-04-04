class CreateEmailLists < ActiveRecord::Migration
  def change
    create_table :email_lists do |t|
      t.references :user
      t.integer :section_id
      t.string :name
      t.boolean :email1
      t.boolean :email2
      t.boolean :email3
      t.boolean :email4
      t.boolean :match_type
      t.integer :match_grouping

      t.timestamps
    end
    add_index :email_lists, :user_id
  end
end
