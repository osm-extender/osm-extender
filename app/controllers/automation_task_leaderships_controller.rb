class AutomationTaskLeadershipsController < AutomationTasksController
  before_action { require_osm_permission :read, :member }
  before_action { require_osm_permission :write, :badge }

  private
  def model
    return AutomationTaskLeadership
  end

end
