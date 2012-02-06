class ProgrammeReviewBalancedCacheController < ApplicationController
  before_filter :require_login
  load_and_authorize_resource

  def destroy
    @programme_review_balanced_cache = ProgrammeReviewBalancedCache.find(params[:id])

    if can? :delete, @programme_review_balanced_cache
      @programme_review_balanced_cache.destroy
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { head :ok }
      end

    else
      redirect_back_or_to_root
    end
  end

end
