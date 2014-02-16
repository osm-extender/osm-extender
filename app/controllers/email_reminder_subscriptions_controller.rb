class EmailReminderSubscriptionsController < ApplicationController
  skip_before_action :require_login, :only => [:edit, :change]


  def edit
    # Display confirmation
    @share = EmailReminderShare.find_by!(id: params[:id], auth_code: params[:auth_code])
    @state = ['subscribed', 'unsubscribed'].include?(params[:state]) ? params[:state].to_sym : @share.state
    @states = get_states(@share)
  end

  def change
    # Actually change
    @share = EmailReminderShare.find_by!(id: params[:id], auth_code: params[:auth_code])
    @state = ['subscribed', 'unsubscribed'].include?(params[:state]) ? params[:state].to_sym : @share.state

    @share.state = @state
    if @share.update(sanatised_params.email_reminder_subscription)
      flash[:notice] = 'Your subscription was updated.'
      redirect_to root_path
    else
      @states = get_states(@share)
      render :edit
    end

  end

  private
  def get_states(share)
    states = [:subscribed, :unsubscribed]
    states.push(:pending) if share.pending?
    return states
  end

end
