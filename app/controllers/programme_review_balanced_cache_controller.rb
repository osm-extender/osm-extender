class ProgrammeReviewBalancedCacheController < ApplicationController
  load_and_authorize_resource

  def destroy
    ProgrammeReviewBalancedCache.for_section(current_section).find(params[:id]).destroy
    redirect_to programme_review_balanced_path
  end

  def destroy_multiple
    ProgrammeReviewBalancedCache.for_section(current_section).destroy_all(:id => params[:ids])
    redirect_to programme_review_balanced_path
  end

end
