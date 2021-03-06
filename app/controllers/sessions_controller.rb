class SessionsController < ApplicationController
  skip_before_action :require_login, :only => [:new, :create, :destroy]
  skip_before_action :require_gdpr_consent, :only => [:new, :create, :destroy]

  def new
  end

  def create
    user = login(params[:email_address].downcase, params[:password])
    Rails.logger.debug "SessionsController#create: user is #{user.inspect}"

    if user
      # since user has remembered their password remove any reset tokens
      user.clear_reset_password_token
      user.save!

      # Set current section
      if current_user.connected_to_osm?
        Rails.logger.debug "SessionsController#create: user is connected to OSM."
        sections = Osm::Section.get_all(osm_api)
        Rails.logger.debug "SessionsController#create: user has access to #{sections.count} sections."
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

      Rails.logger.debug "SessionsController#create: logging, flashing and redirecting."
      flash[:notice] = 'Successfully signed in.'
      redirect_to (session[:return_to_url].nil? ? my_page_path : session.delete(:return_to_url) )
      Rails.logger.debug "SessionsController#create: done!"
    else
      user = User.find_by(email_address: params[:email_address].downcase)
      if user && user.activation_state.eql?('pending')
        flash[:error] = 'You have not yet activated your account.'
        Rails.logger.error 'Non activated account attempted signin.'
      elsif user && !user.lock_expires_at.nil?
        flash[:error] = 'The account was locked.'
        Rails.logger.error 'Locked account attempted signin.'
      else
        flash[:error] = 'Email address or password was invalid.'
        Rails.logger.error 'Email address or password was invalid.'
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
    Osm::Section.get_all(osm_api).each do |section|
      if section_id == section.id
        set_current_section section
        break
      end
    end
    
    redirect_to my_page_path
  end
end
