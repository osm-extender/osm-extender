class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception
  before_action :require_login
  before_action :require_gdpr_consent
  before_action :set_paper_trail_whodunnit
  add_flash_types :information, :error, :warning, :notice, :instruction
  helper_method :current_section, :current_announcements, :has_osm_permission?, :user_has_osm_permission?,
                :api_has_osm_permission?, :get_section_names, :get_group_names, :get_grouping_name,
                :get_current_section_terms, :get_current_term_id, :require_not_login,
                :osm_user_permission_human_friendly, :osm_api_permission_human_friendly,
                :sanatised_params, :editable_params


  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from AbstractController::ActionNotFound, :with => :render_not_found
  end

  rescue_from ActionController::ParameterMissing do |exception|
    @message = "You failed to specify at least one required attribute "
    @message += "(#{exception.param.inspect})."
    log_error(exception)
    email_error(exception)
    render :template => 'error/422', :status => 422
  end

  rescue_from ActionController::UnpermittedParameters do |exception|
    @message = "You specified at least one attribute which you don't have permission to set "
    @message += "(#{exception.params.map{ |i| i.inspect }.join(', ')})."
    log_error(exception)
    email_error(exception)
    render :template => 'error/422', :status => 422
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    render :template => 'error/invalid_authenticity_token', :status => 422
  end


  private
  # What to do when the require_login filter fails
  def not_authenticated
    flash[:error] = 'You must be signed in to access this resource.'
    redirect_to signin_path
  end

  # Sanatise the parameters which can be set by a user
  # e.g. email_list.update(sanatised_params.email_list)
  def sanatised_params
    @sanatised_params ||= SanatisedParams.new(params, current_user)
  end

  # The parameters which are editable by the user
  # e.g. permitted_params.email_list.include?(:name)
  def editable_params
    @editable_params ||= EditableParams.new(current_user)
  end

  # Filter to set @section from :section_id in params
  def get_section_from_params
    @section = Osm::Section.get(osm_api, params[:section_id].to_i)
    if @section.nil?
      render_not_found
    end
  end

  # Filter to require that a user is not logged in
  # @return [Boolean] Whether the user is not logged in ( !current_user )
  def require_not_login
    if current_user
      flash[:error] = 'You must be signed out to do that.'
      redirect_back_or_to my_page_path
      return false
    end
    return true
  end


  # Ensure the user has connected to OSM
  # if not redirect them to the relevant page and set an instruction flash
  # @return [Boolean] Whether the user has connected to their OSM account
  def require_connected_to_osm
    unless current_user.connected_to_osm?
      flash[:instruction] = 'You must connect to your OSM account first.'
      redirect_to(current_user ? connect_to_osm_path : signin_path)
      return false
    end
    return true
  end


  # Filter to require the user has given GDPR consent
  def require_gdpr_consent
    unless current_user.gdpr_consent_at?
      session[:return_to] = request.env['PATH_INFO']
      redirect_to gdpr_consent_path
      return false
    end
    return true
  end


  # Get a human friendly description of how a permission is set for a user in OSM
  def osm_user_permission_human_friendly(permission_on, user=current_user, section=current_section)
    permissions = user.osm_api.get_user_permissions
    permissions = permissions[section.to_i] || {}
    permissions = (permissions[permission_on] || [])
    return 'Administer' if permissions.include?(:administer)
    return 'Read and Write' if permissions.include?(:write)
    return 'Read' if permissions.include?(:read)
    return 'No permissions'
  end

  # Get a human friendly description of how a permission is set for the api in OSM
  def osm_api_permission_human_friendly(permission_on, user=current_user, section=current_section)
    permissions = Osm::ApiAccess.get_ours(user.osm_api, section.to_i).permissions
    permissions = permissions[permission_on] || []
    return 'Administer' if permissions.include?(:administer)
    return 'Read and Write' if permissions.include?(:write)
    return 'Read' if permissions.include?(:read)
    return 'No permissions'
  end

  # Require that the section has a given subscription level (or higher)
  # If not redirect them to my_page and set an error flash
  # @param level [Integer, Symbol] the subscription level required
  # @param section [Osm::Section, Integer, #to_i] the section to check
  # @return [Boolean] Whether the section has that level of subscription
  def require_section_subscription(level, section=current_section)
    section = Osm::Section.get(api, section) unless section.is_a?(Osm::Section)
    if section.nil? || !section.subscription_at_least?(level)
      flash[:error] = "#{section.nil? ? 'Unknown section' : section.name} does not have the right subscription level for that (#{Osm::SUBSCRIPTION_LEVEL_NAMES[level]} subscription or better required)."
      redirect_back_or_to(current_user ? my_page_path : signin_path)
      return false
    end
    return true
  end

  # Ensure the user has a given OSM permission
  # if not redirect them to the osm permissions page and set an error flash
  # @param permission_to the action which is being checked (:read or :write)
  # @param permission_on the object type which is being checked (:member, :register ...), this can be an array in which case the user must be able to perform the action to all objects
  # @return [Boolean] Whether the user has been given the permission
  def require_osm_permission(permission_to, permission_on, user=current_user, section=current_section)
    unless has_osm_permission?(permission_to, permission_on, user, section)
      flash[:error] = 'You do not have the correct OSM permissions to do that.'
      redirect_back_or_to(current_user ? check_osm_setup_path : signin_path)
      return false
    end
    return true
  end

  # Check if the user and API have a given OSM permission
  def has_osm_permission?(permission_to, permission_on, user=current_user, section=current_section)
    user.has_osm_permission?(section, permission_to, permission_on)
  end

  # Check if the user has a given OSM permission
  def user_has_osm_permission?(permission_to, permission_on, user=current_user, section=current_section)
    user.user_has_osm_permission?(section, permission_to, permission_on)
  end

  # Check if the API has a given OSM permission
  def api_has_osm_permission?(permission_to, permission_on, user=current_user, section=current_section)
    user.api_has_osm_permission?(section, permission_to, permission_on)
  end



  # Ensure the user has a given OSMX permission
  # if not redirect them to the osm permissions page and set an instruction flash
  # @param permission_to the action which is being checked (:administer_users or :administer_faqs)
  # @return [Boolean] Whether the user has granted permission to osmx
  def require_osmx_permission(permission_to)
    unless current_user && current_user.send("can_#{permission_to}?")
      # Send user to the osm permissions page
      flash[:error] = 'You are not allowed to do that.'
      redirect_back_or_to(current_user ? my_page_path : signin_path)
      return false
    end
    return true
  end

  # Ensure the section is of a given type
  # if not redirect them to the relevant page and set an instruction flash
  # @param type a Symbol representing the type of section to require (may be :beavers, :cubs ... or an Array of allowable types)
  # @param section an Osm::Section to check (defaults to current_section)
  # @return [Boolean] Whether the section is of the type passed
  def require_section_type(type, section=current_section)
    if section.nil? || ![*type].include?(section.type)
      flash[:error] = "The section must be a #{type} section to do that."
      redirect_back_or_to(current_user ? my_page_path : signin_path)
      return false
    end
    return true
  end

  # Forbid the current section if it is of a given type
  # if so redirect them to the relevant page and set an instruction flash
  # @param type a Symbol representing the type of section to forbid (may be :beavers, :cubs ... or an Array ot them)
  def forbid_section_type(type, section=current_section)
    if section.nil? || [*type].include?(section.type)
      flash[:error] = "The section must not be a #{t} section to do that."
      redirect_back_or_to(current_user ? my_page_path : signin_path)
    end
  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = 'You are not authorised to do that.'
    redirect_to(current_user ? my_page_path : signin_path)
  end


  unless Rails.configuration.consider_all_requests_local
    rescue_from Osm::Error do |exception|
      log_error(exception)
      render :template => "error/osm", :status => 503, :locals => {:exception => exception}
    end
  end

  rescue_from Osm::Error::NoCurrentTerm do |exception|
    unless current_user.nil? || !current_user.connected_to_osm? || exception.section_id.nil?
      section = Osm::Section.get(osm_api, exception.section_id)
      next_term = nil
      last_term = nil
      terms = Osm::Term.get_for_section(osm_api, section)
      terms.each do |term|
        last_term = term if term.past? && (last_term.nil? || term.finish > last_term.finish)
        next_term = term if term.future? && (next_term.nil? || term.start < next_term.start)
      end
      render :template => "error/no_current_term", :status => 503, :locals => {:last_term => last_term, :next_term => next_term, :section => section}
      Osm::Model.cache_delete(osm_api, ['terms', osm_api.user_id]) # Clear cached terms ready for a retry
    else
      render :template => "error/osm", :status => 503, :locals => {:exception => exception}
    end
  end


  def render_not_found
    render :template => "error/404", :status => 404
  end

  def render_error(exception)
    log_error(exception)
    Rollbar.error(exception)
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
    NotifierMailer.exception(exception, env, session).deliver_now
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


  def set_current_section(section)
    fail ArgumentError unless section.is_a?(Osm::Section)
    session[:current_section_id] = section.id
    @current_section = section
  end
  def current_section
    @current_section ||= Osm::Section.get(osm_api, session[:current_section_id])
  end

  def osm_api
    @osm_api ||= current_user.osm_api
  end

  def current_announcements
    @current_announcements ||= (current_user ? current_user.current_announcements : Announcement.are_current.are_public)
  end

  def get_current_section_terms
    @terms ||= {}
    Osm::Term.get_for_section(osm_api, current_section).each do |term|
      @terms[term.name] = term.id
    end
    return @terms
  end

  def get_current_term_id
    @current_term_id ||= Osm::Term.get_current_term_for_section(osm_api, current_section).try(:id)
    return @current_term_id
  end

  def get_current_section_groupings
    get_section_groupings(current_section)
  end

  def get_section_groupings(section)
    @groupings ||= {}
    section_id = section.to_i
    return @groupings[section_id] unless @groupings[section_id].nil?
    @groupings[section_id] = {}
    Osm::Grouping.get_for_section(osm_api, section).each do |grouping|
      @groupings[section_id][grouping.name] = grouping.id
    end
    return @groupings[section_id]
  end

  def get_all_groupings
    return @groupings unless @groupings.nil?
    @groupings = {}
    Osm::Section.get_all(osm_api).each do |section|
      @groupings[section.id] = {}
      if has_osm_permission?(:read, :member, current_user, section)
        Osm::Grouping.get_for_section(osm_api, section).each do |grouping|
          @groupings[section.id][grouping.name] = grouping.id
        end
      end
    end
    return @groupings
  end

  def get_section_names
    @section_names ||= Hash[ Osm::Section.get_all(osm_api).map { |s| [s.id, "#{s.group_name} : #{s.name}"] } ]
  end

  def get_group_names
    @group_names ||= Hash[ Osm::Section.get_all(osm_api).map { |s| [s.group_id, s.group_name] }.uniq ]
  end


  # Get the grouping name (e.g. patrol) for a given section type
  # @param type the type of section (:beavers, :cubs ...)
  # @returns a string
  def get_grouping_name(type)
    {
      :beavers=>'lodge',
      :cubs=>'six',
      :scouts=>'patrol',
      :adults=>'section'
    }[type] || 'grouping'
  end

  # Get the section general name (e.g. troop) for a given section type
  # @param type the type of section (:beavers, :cubs ...)
  # @returns a string
  def get_section_general_name(type)
    {
      :beavers=>'colony',
      :cubs=>'pack',
      :scouts=>'troop',
      :explorers=>'unit',
      :adults=>'section'
    }[type] || 'grouping'
  end

  # Create a UsageLog item setting the following values:
  #  * :at => set by model
  #  * :user => current_user
  #  * :section_id => current_section.id (if current_section is not nil)
  #  * :controller => self.class.name
  #  * :action => action_name
  # @param attributes the attributes for the entry to create
  # @returns Boolean
  def log_usage(attributes={})
    attributes.reverse_merge!(:user => current_user, :controller => self.class.name, :action => action_name)
    attributes[:section_id] = current_section.id if (!attributes.has_key?(:section_id) && current_section)
    UsageLog.create!(attributes)
  end

end
