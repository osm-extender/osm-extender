class EmailReminderItemAdvisedAbsencesController < EmailReminderItemsController
  before_action { require_osm_permission :read, :register }


  private
  def model
    return EmailReminderItemAdvisedAbsence
  end

end
