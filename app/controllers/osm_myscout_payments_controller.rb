class OsmMyscoutPaymentsController < ApplicationController
  before_action :require_connected_to_osm
  before_action { require_section_type Constants::YOUTH_SECTIONS }

  def calculator
  end

end
