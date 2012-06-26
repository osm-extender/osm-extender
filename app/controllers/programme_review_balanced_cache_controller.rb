class ProgrammeReviewBalancedCacheController < ApplicationController
  load_and_authorize_resource

  def destroy
    ProgrammeReviewBalancedCache.for_section(current_section).find(params[:id]).delete

    respond_to do |format|
      format.html { redirect_to programme_review_balanced_path }
      format.json { head :ok }
    end
  end

  def destroy_multiple
    ProgrammeReviewBalancedCache.for_section(current_section).delete_all(:term_id => params[:term_ids])

    respond_to do |format|
      format.html { redirect_to programme_review_balanced_path }
      format.json { head :ok }
    end
  end

end
