class ProgrammeReviewController < ApplicationController
  before_action { require_section_type Constants::YOUTH_SECTIONS }
  before_action :require_connected_to_osm
  before_action { require_osm_permission :read, :programme }

  def balanced
    @methods = ProgrammeReview::METHODS[current_section.type]
    @zones = ProgrammeReview::ZONES[current_section.type]
    @cached_terms = ProgrammeReviewBalancedCache.for_section(current_section)
  end

  def balanced_data
    data = ProgrammeReview.new(current_user, current_section).balanced
    render json: data
  end

end
