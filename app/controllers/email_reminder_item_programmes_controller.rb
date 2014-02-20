class EmailReminderItemProgrammesController < EmailReminderItemsController
  before_action { require_osm_permission :read, :member }

  private
  def model
    return EmailReminderItemProgramme
  end

end
