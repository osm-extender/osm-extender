class EmailReminderItemsController < ApplicationController
  before_action :require_connected_to_osm
  before_action { forbid_section_type :waiting }
  load_and_authorize_resource

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
      :configuration => params[:email_reminder_item].symbolize_keys,
    })

    if @email_reminder_item.save
      redirect_to edit_email_reminder_path(@email_reminder_item.email_reminder), notice: 'Item was successfully added.'
    else
      render action: "new"
    end
  end

  def update
    params[:email_reminder_item] ||= {}
    @email_reminder_item = EmailReminderItem.find(params[:id])

    if @email_reminder_item.update_attributes(:configuration=>params[:email_reminder_item].symbolize_keys)
      redirect_to edit_email_reminder_path(@email_reminder_item.email_reminder), notice: 'Item was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @email_reminder_item = EmailReminderItem.find(params[:id])
    return_to = edit_email_reminder_path(@email_reminder_item.email_reminder)
    @email_reminder_item.destroy

    redirect_to return_to
  end

end
