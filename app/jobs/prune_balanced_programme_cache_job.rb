class PruneBalancedProgrammeCacheJob < ActiveJob::Base
  queue_as :default

  def perform
    deleted = ProgrammeReviewBalancedCache.destroy_all(['last_used_at <= ?', 1.year.ago]).count
    Rails.logger.info "#{deleted} programme review caches deleted."
  end
end
