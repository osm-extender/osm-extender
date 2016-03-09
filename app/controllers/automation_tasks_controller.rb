class AutomationTasksController < ApplicationController
  before_action :require_connected_to_osm
  before_action { forbid_section_type [:adult, :waiting] }
  before_action :check_section_type, except: [:index]
  before_action :check_permissions, except: [:index]
  load_and_authorize_resource except: [:new, :create, :index]
  authorize_resource :only=>[:new, :create, :index]

  def index
    @tasks = AutomationTask.where(['section_id = ?', current_section.id])
    @unused_tasks = AutomationTask.unused_items(current_user, current_section)
  end

  def new
    @task = model.new(user: current_user, section_id: current_section.id)
  end

  def edit
    @task = model.find(params[:id])
  end

  def create
    @task = model.new({
      user: current_user,
      section_id: current_section.id,
      active: (params[:automation_task] || {})[:active].eql?('1'),
      configuration: configuration_params.symbolize_keys,
    })

    if @task.invalid?
      render action: :new, status: 422
    elsif @task.save
      redirect_to automation_tasks_path, notice: 'Task was successfully added.'
    else
      render action: :new, status: 500, error: 'Task could not be added.'
    end
  end

  def update
    @task = model.find(params[:id])
    @task.assign_attributes({
      user: current_user,
      active: (params[:automation_task] || {})[:active].eql?('1'),
      configuration: configuration_params.symbolize_keys,
    })

    if @task.invalid?
      render action: :edit, status: 422
    elsif @task.save
      redirect_to automation_tasks_path, notice: 'Task was successfully updated.'
    else
      render action: :edit, status: 500, error: 'Task could not be updated.'
    end
  end

  def destroy
    @task = model.find(params[:id])
    @task.destroy
    redirect_to automation_tasks_path
  end

  def perform_task
#TODO - check for nil @task
    @task = model.where(['section_id = ? AND type = ?', current_section.to_i, model.to_s]).first
    @task = @task.do_task(current_user)
    if @task[:log_lines].is_a?(Array) && !@task[:log_lines].empty?
      flash[:information] = view_context.html_from_log_lines(@task[:log_lines])
    end

    if @task[:success]
      redirect_to automation_tasks_path, notice: 'Task was successfully performed.'
    else
      error_message = 'Task was unsuccessfully performed.'.html_safe
      if @task[:errors].is_a?(Array) && !@task[:errors].empty?
        error_message << view_context.html_from_log_lines(@task[:errors])
      end
      redirect_to automation_tasks_path, error: error_message
    end
  end


  private
  def configuration_params
    return {} if params[:automation_task_config].nil?
    params[:automation_task_config].permit(model.default_configuration.keys)
  end

  def check_permissions
    unless model.has_permissions?(current_user, current_section)
      flash[:error] = 'You do not have the correct OSM permissions to do that.'
      redirect_back_or_to(current_user ? check_osm_setup_path : signin_path)
    end
  end

  def check_section_type
    require_section_type model::ALLOWED_SECTIONS
  end

end
