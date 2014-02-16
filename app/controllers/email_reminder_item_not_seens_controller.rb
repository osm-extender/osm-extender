class EmailReminderItemNotSeensController < EmailReminderItemsController
  before_action { require_osm_permission :read, :register }

  private
  def model
    return EmailReminderItemNotSeen
  end

end
