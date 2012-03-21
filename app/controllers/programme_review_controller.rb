class ProgrammeReviewController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter { require_osm_permission :read, :programme }

  def balanced
    @methods = ProgrammeReview.methods[current_section.type]
    @zones = ProgrammeReview.zones[current_section.type]
    @cached_terms = ProgrammeReviewBalancedCache.where(['section_id = ?', current_section.id])
    
    @terms = {}
    (current_user.osm_api.get_terms[:data] || []).each do |term|
      @terms[term.id] = term if (term.section_id == current_section.id)
    end
  end

  def balanced_data
    pr = ProgrammeReview.new(current_user, current_section.id)

    render :json => pr.balanced
  end

end
