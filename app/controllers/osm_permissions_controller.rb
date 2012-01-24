class OsmPermissionsController < ApplicationController
  before_filter :require_login

  def view
    @permissions = current_user.osm_permissions(session[:current_section_id])
  end

end
