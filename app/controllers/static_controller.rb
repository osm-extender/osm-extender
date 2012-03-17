class StaticController < ApplicationController
  skip_before_filter :require_login, :only => [:welcome]
  before_filter :require_connected_to_osm, :only => [:osm_permissions]

  def welcome
  end

  def my_page
    if current_user.connected_to_osm?
      @roles = current_user.osm_api.get_roles[:data]
    else
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
      @roles = []
    end
  end

  def osm_permissions
    @permissions = current_user.osm_api.get_our_api_access(session[:current_section_id])[:data]
  end

end
