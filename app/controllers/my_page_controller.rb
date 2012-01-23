class MyPageController < ApplicationController
  before_filter :require_login

  def index
    unless current_user.connected_to_osm?
      flash[:instruction] = "You need to connect your account to your OSM account. #{self.class.helpers.link_to 'Connect now.', connect_to_osm_path}".html_safe
    end
  end
  
end
