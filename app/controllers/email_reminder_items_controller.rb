class EmailReminderItemsController < ApplicationController
  before_action :require_connected_to_osm
  before_action { forbid_section_type :waiting }
  load_and_authorize_resource :except=>[:new, :create]
  authorize_resource :only=>[:new, :create]


  def index
    @email_reminder_items = model.where(['email_reminder_id = ?', params[:email_reminder_id]])
  end

  def show
    @email_reminder_item = model.find(params[:id])
  end

  def new
    @email_reminder_item = model.new(:email_reminder => EmailReminder.find(params[:email_reminder_id]))
  end

  def edit
    @email_reminder_item = EmailReminderItem.find(params[:id])
  end

  def create
    params[:email_reminder_item] ||= {}
    @email_reminder_item = model.new({
      :email_reminder => EmailReminder.find(params[:email_reminder_id]),
      :configuration => configuration_params.symbolize_keys,
    })

    if @email_reminder_item.invalid?
      render action: :new, status: 422
    elsif @email_reminder_item.save
      redirect_to edit_email_reminder_path(@email_reminder_item.email_reminder), notice: 'Item was successfully added.'
    else
      render action: :new, status: 500, error: 'Item could not be added.'
    end
  end

  def update
    params[:email_reminder_item] ||= {}
    @email_reminder_item = EmailReminderItem.find(params[:id])
    @email_reminder_item.assign_attributes(:configuration=>configuration_params.symbolize_keys)

    if @email_reminder_item.invalid?
      render action: :edit, status: 422
    elsif @email_reminder_item.save
      redirect_to edit_email_reminder_path(@email_reminder_item.email_reminder), notice: 'Item was successfully updated.'
    else
      render action: :edit, status: 500, error: 'Item could not be updated.'
    end
  end

  def destroy
    @email_reminder_item = EmailReminderItem.find(params[:id])
    return_to = edit_email_reminder_path(@email_reminder_item.email_reminder)
    @email_reminder_item.destroy

    redirect_to return_to
  end


  private
  def configuration_params
    params[:email_reminder_item].permit(model.default_configuration.keys)
  end

end
