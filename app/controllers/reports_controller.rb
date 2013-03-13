class ReportsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_section_type :youth_section }
  before_filter do
    @allowed_reports = []
    @allowed_reports.push(:test) if has_osm_permission?(:read, :badge)
  end


  def index
  end

end
