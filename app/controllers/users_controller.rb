# TODO Add gravatar to index and edit page
# TODO Add pagnation to index
# TODO Add sorting/filtering to index

class UsersController < ApplicationController
  before_filter :require_login, :except => [:new, :create, :activate_account]
  load_and_authorize_resource :except => [:activate_account]

  def index
    @users = User.find(:all)
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    user = User.find(params[:id])
    if user.update_attributes(params[:user], :as => :admin)
      redirect_to users_path, :notice => 'The user was updated.'
    else
      render :action => :edit
    end
  end

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
    user = User.load_from_activation_token(params[:token].to_s)

    if user && authorize!(:activate_account, user) && user.activate!
      flash[:notice] = 'Your account was successfully activated.'
      redirect_to signin_path
    else
      flash[:error] = 'We were unable to activate your account.'
      redirect_to root_url
    end
  end

  def reset_password
    user = User.find(params[:id])
    authorize! :reset_password, user
    if user.deliver_reset_password_instructions!
      redirect_to(users_path, :notice => 'Password reset instructions have been sent to the user.')
    else
      redirect_to(users_path, :error => 'Password reset instructions have NOT been sent to the user.')
    end
  end

  def resend_activation
    user = User.find(params[:id])
    authorize! :resend_activation, user
    if UserMailer.activation_needed(user).deliver
      redirect_to(users_path, :notice => 'Activation instructions have been sent to the user.')
    else
      redirect_to(users_path, :error => 'Activation instructions have NOT been sent to the user.')
    end
  end

end
