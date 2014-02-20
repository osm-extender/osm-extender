class MyPreferencesController < ApplicationController

  def update
    if current_user.update(:startup_section => params[:startup_section])
      flash[:notice] = 'Your preferences were updated.'
    else
      flash[:error] = 'Your preferences were not updated.'
    end
    redirect_to my_page_path
  end

  def save_custom_sizes
    current_user.custom_row_height = params[:row_height]
    current_user.custom_text_size = params[:text_size]

    render :json => {
      :saved => current_user.save,
    }

  end

end
