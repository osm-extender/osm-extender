class OsmMyscoutPaymentsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_section_type Constants::YOUTH_SECTIONS }

  def calculator
    log_usage(:section_id => nil)
  end

end
