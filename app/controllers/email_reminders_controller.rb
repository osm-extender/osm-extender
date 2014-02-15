class EmailRemindersController < ApplicationController
  before_action :require_connected_to_osm, :except => [:index, :show, :preview, :send_email]
  before_action :except => [:index, :show, :preview, :send_email] do
    forbid_section_type :waiting
  end
  before_action :setup_tertiary_menu
  load_and_authorize_resource :except=>:create

  def index
    @my_reminders = current_user.email_reminders.order(:section_name)
    @shared_reminders = EmailReminderShare.shared_with(current_user)
  end

  def show
    @email_reminder = EmailReminder.find(params[:id])
    @tertiary_menu_items = nil unless @email_reminder.user == current_user
  end

  def new
    @email_reminder = current_user.email_reminders.new(:section_id => current_section.id)
  end

  def edit
    @email_reminder = current_user.email_reminders.find(params[:id])
    @available_items = get_available_items(@email_reminder.section_id)
  end

  def create
    @email_reminder = current_user.email_reminders.new(params[:email_reminder].permit(params[:email_reminder].keys))

    if @email_reminder.save
      flash[:instruction] = 'You must now add some items to your reminder.'
      flash[:notice] = 'Email reminder was successfully created.'
      @available_items = get_available_items(@email_reminder.section_id)
      render action: 'edit'
    else
      render action: "new"
    end
  end

  def update
    @email_reminder = current_user.email_reminders.find(params[:id])

    if @email_reminder.update_attributes(params[:email_reminder].permit(params[:email_reminder].keys))
      redirect_to @email_reminder, notice: 'Email reminder was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @email_reminder = current_user.email_reminders.find(params[:id])
    @email_reminder.destroy

    redirect_to email_reminders_path
  end


  def re_order
    params[:email_reminder_item].each_with_index do |id, index|
      current_user.email_reminders.find(params[:id]).items.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end

  def preview
    @reminder = EmailReminder.find(params[:id])
    @data = @reminder.get_data
    render "reminder_mailer/reminder_email", :layout => 'mail'
  end

  def sample
    @reminder = EmailReminder.find(params[:id])
    @data = @reminder.get_fake_data
    flash.now[:notice] = 'Fake data has been used in order to ensure that all the selected items have something to show.'
    render "reminder_mailer/reminder_email", :layout => 'mail'
  end

  def send_email
    email_reminder = EmailReminder.find(params[:id])
    unless email_reminder.nil?
      email_reminder.send_email :only_to => current_user, :skip_subscribed_check => true
      redirect_to email_reminders_path, notice: 'Email reminder was successfully sent.'
    else
      redirect_to email_reminders_path, error: 'Email reminder could not be sent.'
    end
  end


  private
  def setup_tertiary_menu
    @tertiary_menu_items = [
      ['List of reminders', email_reminders_path],
      ['New reminder', new_email_reminder_path],
    ]
  end

  def get_available_items(section_id)
    items = []
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemBirthday')
      items.push ({:type => EmailReminderItemBirthday, :as_link => has_osm_permission?(:read, :member, current_user, section_id)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemEvent')
      items.push ({:type => EmailReminderItemEvent, :as_link => has_osm_permission?(:read, :events, current_user, section_id)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemProgramme')
      items.push ({:type => EmailReminderItemProgramme, :as_link => has_osm_permission?(:read, :programme, current_user, section_id)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemNotSeen')
      items.push ({:type => EmailReminderItemNotSeen, :as_link => has_osm_permission?(:read, :register, current_user, section_id)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemAdvisedAbsence')
      items.push ({:type => EmailReminderItemAdvisedAbsence, :as_link => has_osm_permission?(:read, :register, current_user, section_id)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemDueBadge')
      items.push ({:type => EmailReminderItemDueBadge, :as_link => has_osm_permission?(:read, :badge, current_user, section_id)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemNotepad')
      items.push ({:type => EmailReminderItemNotepad, :as_link => true})
    end
    return items
  end

end
