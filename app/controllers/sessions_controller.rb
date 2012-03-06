class SessionsController < ApplicationController

  def new
  end

  def create
    user = login(params[:email_address].downcase, params[:password])
    if user
      # prevent session fixation attack
      old_session = {}
      keys_to_preserve = [:user_id, :return_to_url, :last_action_time, :login_time]
      keys_to_preserve.each do |key|
        old_session[key] = session[key] unless session[key].nil?
      end
      reset_session
      old_session.each_key do |key|
        session[key] = old_session[key]
      end

      # Set current section
      if current_user.connected_to_osm?
        current_user.osm_api.get_roles[:data].each do |role|
          if role.default
            session[:current_section_id] = role.section_id
            session[:current_section_name] = "#{role.section_name} (#{role.group_name})"
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
    redirect_to root_url, :notice => 'Sucessfully signed out.'
  end


  def change_section
    section_id = params[:section_id]
    
    # Check user has access to section then change current section
    if current_user.connected_to_osm?
      current_user.osm_api.get_roles[:data].each do |role|
        if section_id.eql?(role.section_id.to_s)
          session[:current_section_id] = role.section_id
          session[:current_section_name] = "#{role.section_name} (#{role.group_name})"
        end
      end
    end
    
    redirect_to my_page_path
  end
end
