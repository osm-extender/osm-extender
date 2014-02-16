class EmailReminderItemBirthdaysController < EmailReminderItemsController
  before_action { require_osm_permission :read, :member }


  private
  def model
    return EmailReminderItemBirthday
  end

end
