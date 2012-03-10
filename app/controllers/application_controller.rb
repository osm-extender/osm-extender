class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login


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

end
