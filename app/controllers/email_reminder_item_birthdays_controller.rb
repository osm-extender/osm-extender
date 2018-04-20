class EmailReminderItemBirthdaysController < EmailReminderItemsController
  before_action { require_osm_permission :read, :member, section: email_reminder.section_id }


  private
  def model
    return EmailReminderItemBirthday
  end

end
