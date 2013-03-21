class EmailReminderItemAdvisedAbsencesController < EmailReminderItemsController
  before_filter { require_osm_permission :read, :register }

  def model
    return EmailReminderItemAdvisedAbsence
  end

end
