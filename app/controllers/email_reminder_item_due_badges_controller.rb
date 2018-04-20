class EmailReminderItemDueBadgesController < EmailReminderItemsController
  before_action { require_osm_permission :read, :badge, section: email_reminder.section_id }

  private
  def model
    return EmailReminderItemDueBadge
  end

end
