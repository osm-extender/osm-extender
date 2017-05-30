class StatusController < ApplicationController
  before_action { require_osmx_permission :view_status }

  def index
    @status = Status.new
  end

end
