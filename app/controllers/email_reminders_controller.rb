class EmailRemindersController < ApplicationController
  before_action :require_connected_to_osm, :except => [:index, :show, :preview, :send_email]
  before_action :except => [:index, :show, :preview, :send_email] do
    forbid_section_type :waiting
  end
  load_and_authorize_resource :except=>[:new, :create]
  authorize_resource :only=>[:new, :create]


  def index
    @my_reminders = current_user.email_reminders.order(:section_name)
    @shared_reminders = EmailReminderShare.shared_with(current_user)
  end

  def show
    @email_reminder = EmailReminder.find(params[:id])
  end

  def new
    @email_reminder = current_user.email_reminders.new(:section_id => current_section.id)
  end

  def edit
    @email_reminder = current_user.email_reminders.find(params[:id])
    @available_items = @email_reminder.unused_items
  end

  def create
    @email_reminder = current_user.email_reminders.new(sanatised_params.email_reminder)

    if @email_reminder.invalid?
      render action: :new, status: 422

    elsif @email_reminder.save
      flash[:instruction] = 'You must now add some items to your reminder.'
      flash[:notice] = 'Email reminder was successfully created.'
      @available_items = @email_reminder.unused_items
      render action: 'edit'

    else
      render action: :new, status: 500, error: 'Email reminder could not be created.'
    end
  end

  def update
    @email_reminder = current_user.email_reminders.find(params[:id])
    @email_reminder.assign_attributes(sanatised_params.email_reminder)

    if @email_reminder.invalid?
      render action: :edit, status: 422
    elsif @email_reminder.save
      redirect_to @email_reminder, notice: 'Email reminder was successfully updated.'
    else
      render action: :edit, status: 500, error: 'Email reminder could not be updated.'
    end
  end

  def destroy
    @email_reminder = current_user.email_reminders.find(params[:id])
    @email_reminder.destroy

    redirect_to email_reminders_path
  end


  def re_order
    ActiveRecord::Base.transaction do
      params[:email_reminder_item].each_with_index do |id, index|
        item = current_user.email_reminders.find(params[:id]).items.find(id)
        item.position = index + 1
        item.save!
      end
    end
    render nothing: true
  end

  def preview
    @reminder = EmailReminder.find(params[:id])
    @data = @reminder.get_data
    render "email_reminder_mailer/reminder_email", :layout => 'mail'
  end

  def sample
    @reminder = EmailReminder.find(params[:id])
    @data = @reminder.get_fake_data
    flash.now[:information] = 'Fake data has been used in order to ensure that all the selected items have something to show.'
    render "email_reminder_mailer/reminder_email", :layout => 'mail'
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

end
