class EmailRemindersController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter :setup_tertiary_menu
  load_and_authorize_resource

  # GET /email_reminders
  # GET /email_reminders.json
  def index
    @email_reminders = current_user.email_reminders.where(['section_id = ?', session[:current_section_id]])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @email_reminders }
    end
  end

  # GET /email_reminders/1
  # GET /email_reminders/1.json
  def show
    @email_reminder = EmailReminder.find(params[:id])
    @tertiary_menu_items.push(['Edit this reminder', edit_email_reminder_path(@email_reminder)])
    @tertiary_menu_items.push(['Preview this reminder', '#preview'])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email_reminder }
    end
  end

  # GET /email_reminders/new
  # GET /email_reminders/new.json
  def new
    @email_reminder = EmailReminder.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email_reminder }
    end
  end

  # GET /email_reminders/1/edit
  def edit
    @email_reminder = EmailReminder.find(params[:id])
  end

  # POST /email_reminders
  # POST /email_reminders.json
  def create
    @email_reminder = current_user.email_reminders.new(params[:email_reminder].merge({:section_id=>session[:current_section_id]}))

    respond_to do |format|
      if @email_reminder.save
        format.html {
          flash[:instruction] = 'You must now add some items to your reminder.'
          flash[:notice] = 'Email reminder was successfully created.'
          render action: 'edit'
        }
        format.json { render json: @email_reminder, status: :created, location: @email_reminder }
      else
        format.html { render action: "new" }
        format.json { render json: @email_reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /email_reminders/1
  # PUT /email_reminders/1.json
  def update
    @email_reminder = EmailReminder.find(params[:id])

    respond_to do |format|
      if @email_reminder.update_attributes(params[:email_reminder])
        format.html { redirect_to @email_reminder, notice: 'Email reminder was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @email_reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_reminders/1
  # DELETE /email_reminders/1.json
  def destroy
    @email_reminder = EmailReminder.find(params[:id])
    @email_reminder.destroy

    respond_to do |format|
      format.html { redirect_to email_reminders_url }
      format.json { head :ok }
    end
  end


  def preview
    email_reminder = EmailReminder.find(params[:id])
    format = ['text'].include?(params[:format]) ? params[:format] : 'text'
    @section_name = get_section_name(email_reminder.section_id)
    @data = email_reminder.get_data
    render "reminder_mailer/reminder_email", :formats => [format]
  end


  private
  def setup_tertiary_menu
    @tertiary_menu_items = [
      ['List of reminders', email_reminders_path],
      ['New reminder', new_email_reminder_path],
    ]
  end

  # Get the name for a given section
  # @param section_id the section ID of the section to get the name for
  # @returns a string containing the section name (will be empty if no section was found or the user can not access that section)
  def get_section_name(section_id)
    if current_user.connected_to_osm?
      current_user.osm_api.get_roles[:data].each do |role|
        if role.section_id == session[:current_section_id]
          return "#{role.section_name} (#{role.group_name})"
        end
      end
    end
    return ''
  end

end
