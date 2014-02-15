class EmailReminderItemProgrammesController < EmailReminderItemsController
  before_action { require_osm_permission :read, :member }

  def model
    return EmailReminderItemProgramme
  end

end
