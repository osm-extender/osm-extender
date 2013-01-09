class SharedEventAttendancesController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { forbid_section_type [:waiting, :adults] }
  before_filter { require_osm_permission [:read, :write], :events }
  before_filter { require_osm_permission :read, [:flexi, :member] }
  load_and_authorize_resource

  def index
    @shared_event_attendances = current_user.shared_event_attendances
  end

  def show
    @shared_event_attendance = current_user.shared_event_attendances.find(params[:id])
  end

  def new
    @shared_event_attendance = current_user.shared_event_attendances.new
    data_for_new
  end

  def edit
    @shared_event_attendance = current_user.shared_event_attendances.find(params[:id])
    data_for_form
    @event = Osm::Event.get(current_user.osm_api, current_section, @shared_event_attendance.event_id)
  end

  def create
    shared_event = SharedEvent.find(params[:se_id].to_i)

    # Create event in OSM
    event = Osm::Event.create(current_user.osm_api, {
      :section_id => current_section.id,
      :name => params[:event_name],
      :location => shared_event.location,
      :start => shared_event.start,
      :finish => shared_event.finish,
      :cost => shared_event.cost,
      :notes => shared_event.notes,
    })
    if event.nil? # Something went wrong
      data_for_new
      flash[:error] = 'Something went wrong creating the event in OSM.'
      render action: "new"
      return
    end

    # Save shared event attendance
    @shared_event_attendance = current_user.shared_event_attendances.new({
      :section_id => current_section.id,
      :event_id => event.id,
    })
    @shared_event_attendance.shared_event = shared_event
    unless @shared_event_attendance.save
      event.delete(current_user.osm_api)
      data_for_new
      flash[:error] = 'Something went wrong saving the event attendance.'
      render action: "new"
      return
    end

    # Process fields
    shared_event.fields.each do |field|
      data_source = params[:field_data][field.id.to_s]
      unless data_source.is_a?(Hash)
        event.delete(current_user.osm_api)
        @shared_event_attendance.destroy
        data_for_new
        flash[:error] = "Something went wrong processing the field for '#{field.name}'."
        render action: "new"
        return
      end
      data_source[:source_type] = data_source[:source_type].to_sym

      data_parameters = {
        :source_type => data_source[:source_type],
      }

      if data_source[:source_type] == :event
        # Create event field
        if event.add_column(current_user.osm_api, data_source[:source_event_name], data_source[:source_event_label])
          event.columns.each do |column|
            if column.name == data_source[:source_event_name]
              data_parameters[:source_field] = column.id
            end
          end
          if data_parameters[:source_field].blank?
            event.delete(current_user.osm_api)
            @shared_event_attendance.destroy
            data_for_new
            flash[:error] = "Something went wrong creating the '#{data_source[:source_event]}' column for the event."
            render action: "new"
            return
          end
        else
          event.delete(current_user.osm_api)
          @shared_event_attendance.destroy
          data_for_new
          flash[:error] = "Something went wrong creating the '#{data_source[:source_event]}' column for the event."
          render action: "new"
          return
        end
      end

      if data_source[:source_type] == :contact_details
        data_parameters[:source_field] = data_source[:source_contact_details].to_sym
      end

      if data_source[:source_type] == :flexi_record
        source_data = data_source[:source_flexi_record].split(':')
        data_parameters[:source_id] = source_data[0]
        data_parameters[:source_field] = source_data[1]
      end

      field_data = @shared_event_attendance.shared_event_field_datas.new(data_parameters)
      field_data.shared_event_field = field
    end


    if @shared_event_attendance.save
      redirect_to shared_event_attendances_path, notice: 'Shared event attendance was successfully created.'
    else
      event.delete(current_user.osm_api) unless event.nil?
      data_for_new
      render action: "new"
    end
  end

  def update
    @shared_event_attendance = current_user.shared_event_attendances.find(params[:id])

    @shared_event_attendance.shared_event_field_datas.each do |field_data|
      form_data = params[:field_data][field_data.id.to_s]
      form_data[:source_type] = form_data[:source_type].to_sym
      field_data.source_type = form_data[:source_type]

      if form_data[:source_type] == :event
        field_data.source_id = nil
        field_data.source_field = form_data[:source_event]
      end

      if form_data[:source_type] == :contact_details
        field_data.source_id = nil
        field_data.source_field = form_data[:source_contact_details].to_sym
      end

      if form_data[:source_type] == :flexi_record
        source_data = form_data[:source_flexi_record].split(':')
        field_data.source_id = source_data[0]
        field_data.source_field = source_data[1]
      end
    end

    if @shared_event_attendance.save
      redirect_to shared_event_attendances_path, notice: 'Shared event attendance was successfully updated.'
    else
      data_for_form
      @event = Osm::Event.get(current_user.osm_api, current_section, @shared_event_attendance.event_id)
      flash[:error] = "Something went wrong updating the attendance for the event."
      render action: "edit"
    end
  end

  def destroy
    @shared_event_attendance = current_user.shared_event_attendances.find(params[:id])
    @shared_event_attendance.destroy

    redirect_to shared_event_attendances_path
  end


  private
  def data_for_new
    @shared_event = SharedEvent.find(params[:se_id])
    data_for_form
  end

  def data_for_form
    @flexi_record_fields = []
    current_section.flexi_records.each do |flexi_record|
      @flexi_record_fields.push [flexi_record.name, [
        *(Osm::FlexiRecord.get_fields(current_user.osm_api, current_section, flexi_record.id).inject([]) { |a, f| a.push [f.name, "#{flexi_record.id}:#{f.id}"] if f.id.match(/\Af_\d+\Z/); a })
      ]]
    end

    @contact_details_fields = current_section.column_names.merge({
      :age => 'Age',
      :date_of_birth => 'Date of birth',
      :started => 'Started Scoting',
      :joining_in_years => 'Joining in years',
      :joined => "Joined #{get_section_general_name(current_section.type)}",
      :joined_years => 'Joined years',
    }).invert
  end

end
