class EmailReminderSharesController < ApplicationController
  skip_before_action :require_login
  load_and_authorize_resource :except => :create


  def index
    @email_reminder_shares = current_user.email_reminder_shares.where('email_reminder_shares.reminder_id = ?', params[:email_reminder_id])
    @email_reminder_share = current_user.email_reminders.find(params[:email_reminder_id]).shares.build
  end
  
  def new
    @email_reminder_share = current_user.email_reminders.find(params[:email_reminder_id]).shares.build
  end
  
  def create
    @email_reminder_share = current_user.email_reminders.find(params[:email_reminder_id]).shares.build(sanatised_params.email_reminder_share)
    authorize! :create, @email_reminder_share

    if @email_reminder_share.save
      flash[:notice] = 'Email reminder was successfully shared.'
      redirect_to email_reminder_shares_path(params[:email_reminder_id])
    else
      render action: 'new'
    end
  end
  
  def destroy
    email_reminder_share = current_user.email_reminder_shares.find(params[:id])
    if email_reminder_share.destroy
      redirect_to email_reminder_shares_path(email_reminder_share.reminder), notice: 'The share was destroyed.'
    else
      redirect_to email_reminder_shares_path(email_reminder_share.reminder), error: 'The share could not be destroyed.'
    end
  end

  def resend_shared_with_you
    email_reminder_share = current_user.email_reminder_shares.find(params[:id])
    unless email_reminder_share.nil?
      ReminderMailer.shared_with_you(email_reminder_share).deliver
      redirect_to email_reminder_shares_path(email_reminder_share.reminder), notice: 'Invitation was successfully resent.'
    else
      redirect_to email_reminder_shares_path(email_reminder_share.reminder), error: 'Invitation could not be resent.'
    end
  end

end
