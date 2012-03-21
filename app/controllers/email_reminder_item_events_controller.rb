class EmailReminderItemEventsController < EmailReminderItemsController
  before_filter { require_osm_permission :read, :programme }

  def model
    return EmailReminderItemEvent
  end

end
