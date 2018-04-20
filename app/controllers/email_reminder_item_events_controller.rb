class EmailReminderItemEventsController < EmailReminderItemsController
  before_action { require_osm_permission :read, :programme, section: email_reminder.section_id }

  private
  def model
    return EmailReminderItemEvent
  end

end
