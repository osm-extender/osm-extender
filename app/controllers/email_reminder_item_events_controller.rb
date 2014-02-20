class EmailReminderItemEventsController < EmailReminderItemsController
  before_action { require_osm_permission :read, :programme }

  private
  def model
    return EmailReminderItemEvent
  end

end
