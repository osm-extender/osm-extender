class MyAccountController < ApplicationController
  before_filter :require_login
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

    if @user && login(@user.email_address, params[:current_password]) # TODO - replace with a check_password method
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
  
  private
  def setup_tertiary_menu
    @tertiary_menu_items = [
      ['Edit Details', edit_my_account_path],
      ['Change Password', change_my_password_path],
    ]
  end

end
