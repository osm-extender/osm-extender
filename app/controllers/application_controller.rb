class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  def not_authenticated
    flash[:error] = 'You must be logged in to access this resource.'
    redirect_to signin_path
  end

end
