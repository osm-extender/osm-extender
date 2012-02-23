class OsmPermissionsController < ApplicationController
  before_filter :require_login
  before_filter :require_connected_to_osm

  def view
    @permissions = current_user.osm_api.get_our_api_access(session[:current_section_id])[:data]
  end

end
