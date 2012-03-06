class MyAccountController < ApplicationController
  before_filter :setup_tertiary_menu

  def show
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    if @user.update_attributes(params)
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
      current_user.osm_api.get_roles[:data].each do |role|
        session[:current_section_id] = role.section_id if role.default
      end

      # Send user to the OSM permissions page
      flash[:instruction] = 'Please use OSM to allow us access to your data, following the intructions below.'
      redirect_to osm_permissions_path, notice: 'Sucessfully connected to your OSM account.'
    else
      render :action => :connect_to_osm
    end
  end

  
  private
  def setup_tertiary_menu
    @tertiary_menu_items = [
      ['Edit Details', edit_my_account_path],
      ['Change Password', change_my_password_path],
    ]
    @tertiary_menu_items.push(['Connect to OSM', connect_to_osm_path]) unless current_user.connected_to_osm?
  end

end
