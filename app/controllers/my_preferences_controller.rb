class MyPreferencesController < ApplicationController

  def update
    if current_user.update_attributes(:startup_section => params[:startup_section])
      flash[:notice] = 'Your preferences were updated.'
    else
      flash[:error] = 'Your preferences were not updated.'
    end
    redirect_to my_page_path
  end

end
