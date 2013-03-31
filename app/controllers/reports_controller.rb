class ReportsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_section_type :youth_section }

  def index
  end

  def due_badges
    require_osm_permission(:read, :badge)
    due_badges = Osm::Badges.get_due_badges(current_user.osm_api, current_section)
    @check_stock = params[:check_stock].eql?('1')
    @by_member = due_badges.by_member
    @badge_totals = due_badges.totals
    @badge_names = due_badges.badge_names
    @member_names = due_badges.member_names
    @badge_stock = @include_stock ? Osm::Badges.get_stock(current_user.osm_api, current_section) : {}
    @by_badge = {}
    @by_member.each do |member_id, badges|
      badges.each do |badge|
        @by_badge[badge] ||= []
        @by_badge[badge].push member_id
      end
    end
  end


end
