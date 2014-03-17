class SharedEventFieldsController < ApplicationController
  load_and_authorize_resource :except=>[:new, :create]
  authorize_resource :only=>[:new, :create]


  def create
    @shared_event_field = current_user.shared_events.find(params[:shared_event_id]).fields.new(shared_event_field_params)

    if @shared_event_field.save
      redirect_to edit_shared_event_path(@shared_event_field.event), notice: "Field was successfully added."
    else
      redirect_to edit_shared_event_path(@shared_event_field.event), error: "Field could not be added."
    end
  end

  def update
    @shared_event_field = current_user.shared_events.find(params[:shared_event_id]).fields.find(params[:id])

    if @shared_event_field.update(shared_event_field_params)
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


  private
  def shared_event_field_params
    params[:shared_event_field].permit(:source_type, :source_id, :source_field)
  end

end
