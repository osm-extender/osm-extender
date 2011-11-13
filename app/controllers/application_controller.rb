class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  def not_authenticated
    flash[:error] = 'You must be signed in to access this resource.'
    redirect_to signin_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = 'You are not authorised to do that.'
    redirect_to root_path
  end

end
