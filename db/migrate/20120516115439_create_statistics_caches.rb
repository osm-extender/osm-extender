class CreateStatisticsCaches < ActiveRecord::Migration
  def change
    create_table :statistics_caches do |t|
      t.date :date, :null => false
      t.integer :users
      t.integer :email_reminders
      t.text :email_reminders_by_day
      t.text :email_reminders_by_type

      t.timestamps
    end

    add_index :statistics_caches, :date, :unique => true

  end
end
