class EmailReminderItemDueBadgesController < EmailReminderItemsController
  before_action { require_osm_permission :read, :badge }

  def model
    return EmailReminderItemDueBadge
  end

end
