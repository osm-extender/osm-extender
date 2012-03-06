class MyPageController < ApplicationController

  def index
    if current_user.connected_to_osm?
      @roles = current_user.osm_api.get_roles[:data]
    else
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
      @roles = []
    end
  end
  
end
