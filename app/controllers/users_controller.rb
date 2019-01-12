class UsersController < ApplicationController
  forbid_login_for = [:new, :create, :activate_account, :unlock_account]
  skip_before_action :require_login, only: forbid_login_for
  skip_before_action :require_gdpr_consent, only: [:gdpr_consent, :gdpr_consent_given] + forbid_login_for
  before_action :require_not_login, only: forbid_login_for
  before_action(only: [:new, :create]) { @signup_code = Figaro.env.signup_code }
  load_and_authorize_resource except: [:new, :create] + forbid_login_for
  authorize_resource only: [:new, :create]
  helper_method :sort_column, :sort_direction

  def index
    params.permit(:sort_column, :sort_direction, :page)
    @users = User.
              search(:name, params[:search_name]).
              search(:email_address, params[:search_email]).
              order(sort_column + " " + sort_direction).
              paginate(:per_page => 10, :page => params[:page]).
              includes(:automation_tasks, :email_reminders, :email_lists)
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user.assign_attributes(params[:user].permit(:name, :email_address, :can_administer_users, :can_view_statistics, :can_view_status, :can_administer_announcements, :can_administer_delayed_job, :can_become_other_user))

    if @user.invalid?
      render action: :edit, status: 422
    elsif @user.save
      redirect_to users_path, :notice => 'The user was updated.'
    else
      render action: :edit, status: 500, error: 'The user could not be updated.'
    end
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user].permit(:name, :email_address, :password, :password_confirmation, :gdpr_consent))
    @user.gdpr_consent ||= false

    if @signup_code
      if params[:signup_code].blank?
        # Missing signup code
        flash.now[:error] = 'You must enter the signup code.'
        render action: :new, status: 422
        return
      else
        unless @signup_code == params[:signup_code]
          # Incorrect signup code
          flash.now[:error] = 'Incorrect signup code.'
          render action: :new, status: 422
          return
        end
      end
    end

    if @user.invalid?
      render action: :new, status: 422

    elsif @user.save
      user = login(params[:user][:email_address], params[:user][:password])
      if user
        redirect_back_or_to root_path, :notice => 'Your signup was successful, you are now signed in.'
      else
        redirect_to root_path, :notice => 'Your signup was successful, please check your email for instructions.'
      end

    else
      flash.now[:error] = 'Your signup was unsuccessful.'
      render action: :new, status: 500
    
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
      redirect_to root_path
    end
  end

  def unlock_account
    user = User.load_from_unlock_token(params[:token].to_s)

    if user && user.login_unlock!
      flash[:notice] = 'Your account was successfully unlocked.'
      redirect_to signin_path
    else
      flash[:error] = 'We were unable to unlock your account.'
      redirect_to root_path
    end
  end

  def reset_password
    user = User.find(params[:id])

    if user.deliver_reset_password_instructions!(expiration: 48.hours)
      redirect_to(users_path, :notice => 'Password reset instructions have been sent to the user.')
    else
      redirect_to(users_path, :error => 'Password reset instructions have NOT been sent to the user.')
    end
  end

  def resend_activation
    user = User.find(params[:id])

    user.send((User.sorcery_config.activation_token_expires_at_attribute_name.to_s + '='), (Time.now.utc + User.sorcery_config.activation_token_expiration_period).to_datetime)
    user.save

    if UserMailer.activation_needed(user).deliver_later
      redirect_to(users_path, :notice => 'Activation instructions have been sent to the user.')
    else
      redirect_to(users_path, :error => 'Activation instructions have NOT been sent to the user.')
    end
  end

  def unlock
    user = User.find(params[:id])
    if user.login_unlock!
      redirect_to users_path, :notice => 'The user was unlocked.'
    else
      render :action => :edit
    end
  end

  def become
    user = User.find(params[:id])
    if user
      current_user = user
      session[:user_id] = user.id
      # Set current section
      if current_user.connected_to_osm?
        sections = Osm::Section.get_all(osm_api)
        set_current_section sections.first
        if current_user.startup_section?
          sections.each do |section|
            if section.id == current_user.startup_section
              set_current_section section
              break
            end
          end
        end
      end
      redirect_to my_page_path, :notice => 'Switched user.'
    else
      redirect_to(users_path, :error => 'The user was not found.')
    end
  end

  def gdpr_consent_given
    if params[:gdpr_consent].eql?('1')
      if current_user.update gdpr_consent_at: Time.now.utc
        redirect_to session[:return_to].nil? ? my_page_path : session.delete(:return_to), :notice => 'Thank you, your consent has been recorded.'
      else
        redirect_to gdpr_consent_path, error: 'Sorry something went wrong, please retry.'
      end
    else
      flash[:error] = 'You must check the box to give consent.'
      render action: :gdpr_consent, status: 422
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
