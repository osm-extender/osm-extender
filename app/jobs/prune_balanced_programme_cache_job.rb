class PruneBalancedProgrammeCacheJob < ApplicationJob
  queue_as :default

  def perform
    deleted = ProgrammeReviewBalancedCache.where(['last_used_at <= ?', 1.year.ago]).destroy_all.count
    Rails.logger.info "#{deleted} programme review caches deleted."
  end
end
