class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create, :activate_account]
  load_and_authorize_resource :except => [:activate_account]
  helper_method :sort_column, :sort_direction

  def index
    @users = User.
              search(:name, params[:search_name]).
              search(:email_address, params[:search_email]).
              order(sort_column + " " + sort_direction).
              paginate(:per_page => 10, :page => params[:page])
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
    @signup_code = params[:signup_code]
  end
  
  def create
    signup_code = Settings.read('signup code')
    unless signup_code.blank?
      unless signup_code.eql?(params[:signup_code])
        flash[:error] = 'Incorrect signup code.'
        render :action => :new and return
      end
    end

    @user = User.new(params[:user])
    if @user.save
      user = login(params[:user][:email_address], params[:user][:password])
      if user
        redirect_back_or_to root_url, :notice => 'Your signup was successful, you are now signed in.'
      else
        redirect_to root_url, :notice => 'Your signup was successful, please check your email for instructions.'
      end
    else
      @signup_code = params[:signup_code]
      render :new
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    flash[:notice] = 'The user was deleted.'
    redirect_to users_path
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

    if user.deliver_reset_password_instructions!
      redirect_to(users_path, :notice => 'Password reset instructions have been sent to the user.')
    else
      redirect_to(users_path, :error => 'Password reset instructions have NOT been sent to the user.')
    end
  end

  def resend_activation
    user = User.find(params[:id])

    user.send((User.sorcery_config.activation_token_expires_at_attribute_name.to_s + '='), (Time.now.utc + User.sorcery_config.activation_token_expiration_period).to_datetime)
    user.save

    if UserMailer.activation_needed(user).deliver
      redirect_to(users_path, :notice => 'Activation instructions have been sent to the user.')
    else
      redirect_to(users_path, :error => 'Activation instructions have NOT been sent to the user.')
    end
  end

  def unlock
    user = User.find(params[:id])
    if user.unlock
      redirect_to users_path, :notice => 'The user was unlocked.'
    else
      render :action => :edit
    end
  end


  private  
  def sort_column
    %w{id name email_address}.include?(params[:sort_column]) ? params[:sort_column] : "id"
  end
  
  def sort_direction
    %w{asc desc}.include?(params[:sort_direction]) ? params[:sort_direction] : "asc"
  end

end
