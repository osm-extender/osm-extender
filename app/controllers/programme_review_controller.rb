class ProgrammeReviewController < ApplicationController
  before_filter :require_login
  before_filter :require_connected_to_osm

  def balanced
    section = current_user.osm_api.get_section session[:current_section_id]
    @methods = ProgrammeReview.methods[section.type]
    @zones = ProgrammeReview.zones[section.type]
    @cached_terms = ProgrammeReviewBalancedCache.where(['section_id = ?', section.id])
    
    @terms = {}
    (current_user.osm_api.get_terms[:data] || []).each do |term|
      @terms[term.id] = term if (term.section_id == section.id)
    end

    @use_jquery = true
    @use_charts = true
  end

  def balanced_data
    section = current_user.osm_api.get_section session[:current_section_id]
    pr = ProgrammeReview.new(current_user, section.id)

    render :json => pr.balanced
  end

end
