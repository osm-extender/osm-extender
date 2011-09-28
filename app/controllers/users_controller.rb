class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create, :activate_account]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      user = login(params[:user][:email_address], params[:user][:password])
      if user
        redirect_back_or_to root_url, :notice => 'Your signup was successful, you are now signed in.'
      else
        redirect_to root_url, :notice => 'Your signup was successful.'
      end
    else
      render :new
    end
  end
  
  def activate_account
    user = User.load_from_activation_token(params[:id])

    if user && user.activate!
      flash[:notice] = 'Your account was successfully activated.'
      redirect_to signin_path
    else
      flash[:error] = 'We were unable to activate your account.'
      redirect_to root_url
    end
  end

end
