class MyPageController < ApplicationController
  before_filter :require_login

  def index
    flash[:warning] = 'You need to connect your account to your OSM account.' unless current_user.connected_to_osm?
  end
  
end
