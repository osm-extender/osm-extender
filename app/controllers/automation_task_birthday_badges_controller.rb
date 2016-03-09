class AutomationTaskBirthdayBadgesController < AutomationTasksController
  before_action { require_osm_permission :read, :member }
  before_action { require_osm_permission :write, :badge }
  before_action :set_badges, only: [:new, :create, :edit, :update]

  private
  def model
    return AutomationTaskBirthdayBadge
  end

  def set_badges
    @badges = Osm::CoreBadge.get_badges_for_section(current_user.osm_api, current_section)
    @badges.select!{ |badge| badge.name.downcase.include?('birthday') }
    @badges.map!{ |badge| [badge.name, badge.id] }
    @badges.sort_by!{ |badge| badge[0].match(/(\d+)/)[1].to_i }
  end

end
