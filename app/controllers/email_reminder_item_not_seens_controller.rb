class EmailReminderItemNotSeensController < EmailReminderItemsController
  before_filter { require_osm_permission :read, :register }

  def model
    return EmailReminderItemNotSeen
  end

end
