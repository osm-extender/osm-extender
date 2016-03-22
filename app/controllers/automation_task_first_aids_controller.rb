class AutomationTaskFirstAidsController < AutomationTasksController
  before_action { require_osm_permission :write, :badge }

  private
  def model
    return AutomationTaskFirstAid
  end

end
