class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create, :destroy]

  def new
  end

  def create
    user = login(params[:email_address].downcase, params[:password])
    if user
      # since user has remembered their password remove any reset tokens
      user.clear_reset_password_token
      user.save!

      # prevent session fixation attack
      old_session = {}
      keys_to_preserve = [:user_id, :return_to_path, :return_to_url, :last_action_time, :login_time]
      keys_to_preserve.each do |key|
        old_session[key] = session[key] unless session[key].nil?
      end
      reset_session
      old_session.each_key do |key|
        session[key] = old_session[key]
      end

      # Set current section
      if current_user.connected_to_osm?
        sections = Osm::Section.get_all(current_user.osm_api)
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
      
      redirect_back_or_to my_page_path, :notice => 'Sucessfully signed in.'
    else
      user = User.find_by_email_address(params[:email_address].downcase)
      if user && user.activation_state.eql?('pending')
        flash[:error] = 'You have not yet activated your account.'
      elsif user && !user.lock_expires_at.nil?
        flash[:error] = 'The account was locked.'
      else
        flash[:error] = 'Email address or password was invalid.'
      end
      render :new
    end
  end
  
  def destroy
    logout
    reset_session
    redirect_to root_path, :notice => 'Sucessfully signed out.'
  end


  def change_section
    require_connected_to_osm
    section_id = params[:section_id].to_i

    # Check user has access to section then change current section
    Osm::Section.get_all(current_user.osm_api).each do |section|
      if section_id == section.id
        set_current_section section
        break
      end
    end
    
    redirect_to my_page_path
  end
end
