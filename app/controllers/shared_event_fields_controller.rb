class SharedEventFieldsController < ApplicationController
  load_and_authorize_resource :except => :create

  def create
    @shared_event_field = current_user.shared_events.find(params[:shared_event_id]).fields.new(params[:shared_event_field])

    if @shared_event_field.save
      redirect_to edit_shared_event_path(@shared_event_field.event), notice: "Field was successfully added."
    else
      redirect_to edit_shared_event_path(@shared_event_field.event), error: "Field could not be added."
    end
  end

  def update
    @shared_event_field = current_user.shared_events.find(params[:shared_event_id]).fields.find(params[:id])

    if @shared_event_field.update(params[:shared_event_field])
      redirect_to edit_shared_event_path(@shared_event_field.event), notice: "Field was successfully updated."
    else
      redirect_to edit_shared_event_path(@shared_event_field.event), error: "Field was not updated."
    end
  end

  def destroy
    @shared_event_field = current_user.shared_events.find(params[:shared_event_id]).fields.find(params[:id])
    @shared_event_field.destroy

    redirect_to edit_shared_event_path(@shared_event_field.event), notice: "Field was successfully removed."
  end

end
