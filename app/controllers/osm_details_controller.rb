class OsmDetailsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :member }

  def select_fields
  end

  def show
    if params[:fields].nil?
      flash[:error] = 'You must select some fields to view.'
      redirect_to osm_details_fields_path and return
    end

    @fields = []
    current_section.column_names.except(:patrol).keys.each do |key|
      @fields.push(key) if params[:fields][key]
    end
    @members = Osm::Member.get_for_section(current_user.osm_api, current_section)

    # Get Totals & Counts
    @totals = {}
    @counts = {}
    @fields.each do |field|
      @totals[field] = 0
      @counts[field] = 0
    end

    @members.each do |member|
      @fields.each do |field|
        value = member.send(field)
        @totals[field] += value.to_i
        @counts[field] += 1 unless (value.blank? || value[0].eql?('x'))
      end
    end
    log_usage
  end

end