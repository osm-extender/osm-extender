class SharedEventsController < ApplicationController
  load_and_authorize_resource

  def index
    @shared_events = current_user.shared_events
  end

  def show
    @shared_event = current_user.shared_events.find(params[:id])
    @attendees_data = @shared_event.get_attendees_data
  end

  def new
    @shared_event = current_user.shared_events.new
  end

  def edit
    @shared_event = current_user.shared_events.find(params[:id])
    @new_field = SharedEventField.new(:event => @shared_event)
  end

  def create
    @shared_event = current_user.shared_events.new(params[:shared_event])

    if @shared_event.save
      flash[:instruction] = "You MUST add any extra fields you need BEFORE other sections use the event."
      redirect_to edit_shared_event_path(@shared_event), notice: "#{@shared_event.name} was successfully created."
    else
      render action: "new"
    end
  end

  def update
    @shared_event = current_user.shared_events.find(params[:id])

    if @shared_event.update_attributes(params[:shared_event])
      redirect_to shared_events_path, notice: "#{@shared_event.name} was successfully updated."
    else
      @new_field = SharedEventField.new(:event => @shared_event)
      render action: "edit"
    end
  end

  def destroy
    @shared_event = current_user.shared_events.find(params[:id])
    @shared_event.destroy

    redirect_to shared_events_path
  end

end
