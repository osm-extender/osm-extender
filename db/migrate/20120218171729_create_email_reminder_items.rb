class CreateEmailReminderItems < ActiveRecord::Migration[4.2]
  def change
    create_table :email_reminder_items do |t|
      t.references :email_reminder
      t.string :type
      t.text :configuration

      t.timestamps
    end
    add_index :email_reminder_items, :email_reminder_id
    add_index :email_reminder_items, :type
  end
end
