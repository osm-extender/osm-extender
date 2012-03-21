class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login
  helper_method :section_name, :current_role, :current_section, :has_osm_permission?


  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from AbstractController::ActionNotFound, :with => :render_not_found
  end


  private
  def not_authenticated
    flash[:error] = 'You must be signed in to access this resource.'
    redirect_to signin_path
  end


  # Ensure the user has connected to OSM
  # if not redirect them to the relevant page and set an instruction flash
  def require_connected_to_osm
    unless current_user.connected_to_osm?
      # Send user to the connect to OSM page
      flash[:instruction] = 'You must connect to your OSM account first.'
      redirect_to connect_to_osm_path
    end
  end


  # Ensure the user has a given OSM permission
  # if not redirect them to the osm permissions page and set an instruction flash
  # @param permission_to the action which is being checked (:read or :write)
  # @param permission_on the object type which is being checked (:member, :register ...), this can be an array in which case the user must be able to perform the action to all objects
  def require_osm_permission(permission_to, permission_on)
    unless has_osm_permission?(permission_to, permission_on)
      # Send user to the osm permissions page
      flash[:error] = 'You do not have the correct OSM permissions to do that.'
      redirect_to osm_permissions_path
    end
  end

  # Check if the user has a given OSM permission
  # if not redirect them to the osm permissions page and set an instruction flash
  # @param permission_to the action which is being checked (:read or :write)
  # @param permission_on the object type which is being checked (:member, :register ...), this can be an array in which case the user must be able to perform the action to all objects
  def has_osm_permission?(permission_to, permission_on)
    permission_on = [permission_on] unless permission_on.is_a?(Array)

    permission_on.each do |on|
      osmx_permissions = current_user.osm_api.get_our_api_access(current_section.id)[:data]
      osmx_can = osmx_permissions.send("can_#{permission_to.to_s}?", on)
      user_can = current_role.send("can_#{permission_to.to_s}?", on)
      return false unless (osmx_can && user_can)
    end

    return true
  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = 'You are not authorised to do that.'
    redirect_to current_user ? my_page_path : signin_path
  end


  def render_not_found(exception)
    render :template => "error/404", :status => 404
  end

  def render_error(exception)
    log_error(exception)
    email_error(exception)
    render :template => "error/500", :status => 500
  end

  def log_error(exception)
    logger.error(
      "\n\n#{exception.class} (#{exception.message}):\n    " +
      Rails.backtrace_cleaner.send(:filter, exception.backtrace).join("\n    ") +
      "\n\n"
    )
  end

  def email_error(exception)
    NotifierMailer.exception(exception, env).deliver unless Settings.read('notifier mailer - send exception to').blank?
  end

  def clean_backtrace(exception)
    if backtrace = exception.backtrace
      if defined?(RAILS_ROOT)
        backtrace.map { |line| line.sub RAILS_ROOT, '' }
      else
        backtrace
      end
    end
  end

  # Get section name in a consistent format
  # @param role (optional) an OSM::Role object to get the name for, defaults to the current role for the session
  # @returns a string
  def section_name(role=session[:current_role])
    return '' unless role.is_a?(OSM::Role)
    "#{role.section_name} (#{role.group_name})"
  end
  def current_role
    session[:current_role]
  end
  def current_section
    session[:current_role].section
  end

end
