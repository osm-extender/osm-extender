class EmailReminderItemDueBadgesController < EmailReminderItemsController
  before_filter { require_osm_permission :read, :badge }

  def model
    return EmailReminderItemDueBadge
  end

end
