class OsmFlexiRecordsController < ApplicationController
  before_action :require_connected_to_osm
  before_action :get_section_from_params, :except=>:index
  before_action :except=>:index do
    forbid_section_type :waiting, @section
  end
  before_action :except=>:index do
    require_osm_permission :read, :flexi, current_user, @section
  end

  def index
    sections = Osm::Section.get_all(osm_api)
    sections.select!{ |s| !s.waiting? }

    @records = {}
    @section_ids = []
    @no_permissions = []

    sections.each do |section|
      @section_ids.push section.id
      if has_osm_permission?(:read, :flexi, current_user, section)
        records = section.flexi_records.sort
        @records[section.id] = records
      else
        @no_permissions.push section.id
      end
    end
  end

  def index_for_section
    @records = @section.flexi_records.sort
  end

  def show
    @record = nil
    record_id = params[:record_id].to_i

    @section.flexi_records.each do |record|
      if record.id == record_id
        @record = record
        break
      end
    end

    if @record.nil? # Record doesn't exist
      render_not_found and return
    end

    @fields = @record.get_columns(osm_api)
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

    @records = @record.get_data(osm_api)
    @records.each do |record|
      @total_count_fields.each do |field|
        @totals[field] += record.fields[field].to_i
        @counts[field] += 1 unless (record.fields[field].blank? || record.fields[field][0].eql?('x'))
      end
    end

    log_usage(:extra_details => {record_id: params[:record_id], section_id: params[:section_id]})
  end

end
