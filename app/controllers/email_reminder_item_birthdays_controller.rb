class EmailReminderItemBirthdaysController < EmailReminderItemsController
  before_action { require_osm_permission :read, :member }

  def model
    return EmailReminderItemBirthday
  end

end
