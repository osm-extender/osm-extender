class EmailReminderItemBirthdaysController < EmailReminderItemsController
  before_filter { require_osm_permission :read, :member }

  def model
    return EmailReminderItemBirthday
  end

end
