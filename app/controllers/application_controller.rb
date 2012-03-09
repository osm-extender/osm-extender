class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login


  private
  def not_authenticated
    flash[:error] = 'You must be signed in to access this resource.'
    redirect_to signin_path
  end


  # Ensure the user has connected to OSM
  # if not redirect them to the relevant page and set an instruction flash
  def require_connected_to_osm
    unless current_user.connected_to_osm?
      # Send user to the connect to OSM page
      flash[:instruction] = 'You must connect to your OSM account first.'
      redirect_to connect_to_osm_path
    end
  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = 'You are not authorised to do that.'
    redirect_to current_user ? my_page_path : signin_path
  end

end
