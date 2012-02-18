class CreateEmailReminders < ActiveRecord::Migration
  def change
    create_table :email_reminders do |t|
      t.references :user
      t.integer :section_id
      t.integer :send_on

      t.timestamps
    end
    add_index :email_reminders, :user_id
    add_index :email_reminders, :section_id
    add_index :email_reminders, :send_on
  end
end
