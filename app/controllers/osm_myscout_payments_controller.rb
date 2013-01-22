class OsmMyscoutPaymentsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter :require_youth_section

  def calculator
  end

end
