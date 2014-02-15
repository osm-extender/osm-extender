class EmailReminderItemAdvisedAbsencesController < EmailReminderItemsController
  before_action { require_osm_permission :read, :register }

  def model
    return EmailReminderItemAdvisedAbsence
  end

end
