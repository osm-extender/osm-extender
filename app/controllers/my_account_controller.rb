class MyAccountController < ApplicationController
  before_action :setup_tertiary_menu

  def show
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    unless @user.email_address.downcase == params[:email_address].downcase
      # Email address is being changed
      unless User.authenticate(@user.email_address, params[:current_password]) == @user
        flash[:error] = 'Incorrect current password.'
        render :action => :edit
        return
      end
    end

    if @user.update_attributes(params.permit(:name, :email_address))
      redirect_to my_account_path, notice: 'Sucessfully updated your details.'
    else
      render :action => :edit
    end
  end

  def change_password
    @user = current_user
  end
  
  def update_password
    @user = current_user

    if User.authenticate(@user.email_address, params[:current_password]) == @user
      if @user.change_password!(params[:new_password], params[:new_password_confirmation])
        redirect_to my_account_path, notice: 'Sucessfully changed your password.'
      else
        render :action => :change_password
      end
    else
      flash[:error] = 'Incorrect current password.'
      render :action => :change_password
    end
  end

  def connect_to_osm
  end

  def connect_to_osm2
    if current_user.connect_to_osm(params[:email], params[:password])
      # Set current section
      set_current_section Osm::Section.get_all(current_user.osm_api).first

      # Send user to the OSM permissions page
      flash[:instruction] = 'Please use OSM to allow us access to your data, following the intructions below.'
      redirect_to check_osm_setup_path, notice: 'Sucessfully connected to your OSM account.'
    else
      render :action => :connect_to_osm
    end
  end

  def confirm_delete
    @currently_have = Hash.new
    @currently_have['reminder email'] = current_user.email_reminders.count if current_user.email_reminders.count > 0
    @currently_have['email list'] = current_user.email_lists.count if current_user.email_lists.count > 0
    @currently_have['shared event'] = current_user.shared_events.count if current_user.shared_events.count > 0
    @currently_have['shared event attendace'] = current_user.shared_event_attendances.count if current_user.shared_event_attendances.count > 0

    @confirmation_code = SecureRandom.hex(32)
    session[:delete_my_account_confrmation_code] = @confirmation_code
  end

  def delete
    # Check the confirmation code from the confirm_delete page
    unless session[:delete_my_account_confrmation_code].eql?(params[:confirmation_code])
      redirect_to confirm_delete_my_account_path
      return
    end

    # Check password
    unless User.authenticate(current_user.email_address, params[:password]) == current_user
      flash[:error] = 'Incorrect password.'
      redirect_to confirm_delete_my_account_path
      return
    end

    if current_user.destroy
      logout
      reset_session
      flash[:notice] = 'Your account was deleted.'
      redirect_to root_path
    else
      flash[:error] = 'Sorry something went wrong.'
      redirect_to confirm_delete_my_account_path
    end
  end
  
  private
  def setup_tertiary_menu
    @tertiary_menu_items = [
      ['Edit Details', edit_my_account_path],
      ['Change Password', change_my_password_path],
      ['Delete Account', confirm_delete_my_account_path]
    ]
    @tertiary_menu_items.push(['Connect to OSM', connect_to_osm_path]) unless current_user.connected_to_osm?
  end

end
