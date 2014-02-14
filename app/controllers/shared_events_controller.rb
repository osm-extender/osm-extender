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
    unless (Date.today < Date.new(2013, 11, 25))
      redirect_to shared_events_path, error: "You can no longer create new shared events" and return
    end
    @shared_event = current_user.shared_events.new
  end

  def edit
    @shared_event = current_user.shared_events.find(params[:id])
    @new_field = SharedEventField.new(:event => @shared_event)
  end

  def create
    @shared_event = current_user.shared_events.new(params[:shared_event].permit(params[:shared_event].keys))

    if @shared_event.save
      flash[:instruction] = "You MUST add any extra fields you need BEFORE other sections use the event."
      redirect_to edit_shared_event_path(@shared_event), notice: "#{@shared_event.name} was successfully created."
    else
      render action: "new"
    end
  end

  def update
    @shared_event = current_user.shared_events.find(params[:id])

    if @shared_event.update_attributes(params[:shared_event].permit(params[:shared_event].keys))
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

  def export
    shared_event = current_user.shared_events.find(params[:shared_event_id])
    fields = shared_event.fields
    data = []
    shared_event.get_attendees_data.each do |section_name, attendees|
      attendees.each do |attendee|
        data.push attendee.merge(
          :section_name => section_name,
          :leader => (attendee[:adult] ? 'Yes' : 'No'),
        )
      end
    end

    options = {
      :col_sep => {'csv' => ',', 'tsv' => "\t"}[params[:format]],
      :write_headers => true,
      :force_quotes => true,
      :quote_char => '"',
      :skip_blanks => true,
      :headers => ['Section', 'First name', 'Last name', 'Adult', *fields.map{ |f| f.name }],
    }
    csv_string = CSV.generate(options) do |csv|
      data.each do |item|
        csv << item.values_at(:section_name, :first_name, :last_name, :leader, *fields.map{ |f| f.id })
      end
    end
    send_data csv_string, :filename => "#{shared_event.name}.#{params[:format]}", :type => "text/#{params[:format]}", :disposition => 'attachment'
  end

end
