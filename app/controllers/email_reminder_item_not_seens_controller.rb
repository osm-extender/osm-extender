class EmailReminderItemNotSeensController < EmailReminderItemsController
  before_action { require_osm_permission :read, :register, section: email_reminder.section_id }

  private
  def model
    return EmailReminderItemNotSeen
  end

end
