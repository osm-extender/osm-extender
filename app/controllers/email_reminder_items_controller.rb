class EmailReminderItemsController < ApplicationController
  before_filter :require_login
  load_and_authorize_resource

  def index
    @email_reminder_items = model.where(['email_reminder_id = ?', params[:email_reminder_id]])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @email_reminder_items }
    end
  end

  def show
    @email_reminder_item = model.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email_reminder_item }
    end
  end

  def new
    @email_reminder_item = model.new(:email_reminder => EmailReminder.find(params[:email_reminder_id]))

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email_reminder_item }
    end
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

    respond_to do |format|
      if @email_reminder_item.save
        format.html { redirect_to edit_email_reminder_path(@email_reminder_item.email_reminder), notice: 'Item was successfully added.' }
        format.json { render json: @email_reminder_item, status: :created, location: @email_reminder_item }
      else
        format.html { render action: "new" }
        format.json { render json: @email_reminder_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:email_reminder_item] ||= {}
    @email_reminder_item = EmailReminderItem.find(params[:id])

    respond_to do |format|
      if @email_reminder_item.update_attributes(:configuration=>params[:email_reminder_item].symbolize_keys)
        format.html { redirect_to edit_email_reminder_path(@email_reminder_item.email_reminder), notice: 'Item was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @email_reminder_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @email_reminder_item = EmailReminderItem.find(params[:id])
    return_to = edit_email_reminder_path(@email_reminder_item.email_reminder)
    @email_reminder_item.destroy

    respond_to do |format|
      format.html { redirect_to return_to }
      format.json { head :ok }
    end
  end

end
