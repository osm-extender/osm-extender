class PasswordResetsController < ApplicationController
  skip_before_filter :require_login

  def new
  end

  def create 
    @user = User.find_by_email_address(params[:email_address])
    @user.deliver_reset_password_instructions! if @user
    redirect_to(root_path, :notice => 'Instructions have been sent to your email address.')
  end

  def edit
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)
    not_authenticated if !@user
  end

  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    if @user && @user.change_password!(params[:password], params[:password_confirmation])
      user = login(@user.email_address, params[:password])
      if user
        redirect_to root_path, :notice => 'Password sucessfully changed. Sucessfully signed in.'
      else
        redirect_to root_path, :notice => 'Password sucessfully changed.'
      end
    else
      render :action => :edit
    end
  end
end
