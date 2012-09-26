class OsmFlexiRecordsController < ApplicationController
  before_filter { forbid_section_type :waiting }
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :flexi }

  def index
    @records = []
    current_section.flexi_records.each do |record|
      @records.push record
    end
    @records.sort!
  end

  def show
    @record = nil
    params[:id] = params[:id].to_i

    current_section.flexi_records.each do |record|
      @record = record if record.id == params[:id]
      @role = current_role
      break
    end

    if @record.nil? # Record not found for current section, user might still be allowed access though
      current_user.osm_api.get_roles.each do |role|
        role.section.flexi_records.each do |record|
          if record.id == params[:id]
            @record = record
            @role = role
            break
          end
        end
      end
    end

    render_not_found(nil) if @record.nil? # Record isn't accessible by this user

    @fields = current_user.osm_api.get_flexi_record_fields(@role.section, @record.id)
    @records = current_user.osm_api.get_flexi_record_data(@role.section, @record.id)
    @field_order = @fields.map{ |field| field.id}

  end

end