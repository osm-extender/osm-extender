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
    @field_order = []
    @field_order = @fields.map{ |field| field.id }


    # Get Totals & Counts
    @total_count_fields = @field_order.select{ |field| field.match(/\Af_\d+\Z/) || ['total'].include?(field) }
    @totals = {}
    @counts = {}
    @total_count_fields.each do |field|
      @totals[field] = 0
      @counts[field] = 0
    end

    @records = current_user.osm_api.get_flexi_record_data(@role.section, @record.id)
    @records.each do |record|
      @total_count_fields.each do |field|
        @totals[field] += record.fields[field].to_i
        @counts[field] += 1 unless (record.fields[field].blank? || record.fields[field][0].eql?('x'))
      end
    end

  end

end