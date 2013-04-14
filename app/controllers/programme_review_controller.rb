class ProgrammeReviewController < ApplicationController
  before_filter { require_section_type :youth_section }
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :programme }

  def balanced
    @methods = ProgrammeReview.methods[current_section.type]
    @zones = ProgrammeReview.zones[current_section.type]
    @cached_terms = ProgrammeReviewBalancedCache.for_section(current_section)
    
    @term_names = {}
    Osm::Term.get_for_section(current_user.osm_api, current_section).each do |term|
      @term_names[term.id] = term.name
    end
  end

  def balanced_data
    data = ProgrammeReview.new(current_user, current_section).balanced
    render :json => data
  end

end
