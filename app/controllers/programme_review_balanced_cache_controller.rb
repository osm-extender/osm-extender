class ProgrammeReviewBalancedCacheController < ApplicationController
  load_and_authorize_resource

  def destroy
    ProgrammeReviewBalancedCache.for_section(current_section).find(params[:id]).delete
    redirect_to programme_review_balanced_path
  end

  def destroy_multiple
    ProgrammeReviewBalancedCache.for_section(current_section).delete_all(:term_id => params[:term_ids])
    redirect_to programme_review_balanced_path
  end

end
