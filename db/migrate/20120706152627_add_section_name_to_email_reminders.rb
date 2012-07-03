class AddSectionNameToEmailReminders < ActiveRecord::Migration

  def up
    add_column :email_reminders, :section_name, :string

    # Get names for existing records
    EmailReminder.all.each do |reminder|
      reminder.save!  # Causes validations (including set_section_name) to run
    end

    change_column  :email_reminders, :section_name, :string, :null => false
  end

  def down
    remove_column :email_reminders, :section_name
  end

end
