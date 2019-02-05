class PrunePaperTrailsJob < ApplicationJob
  queue_as :default

  def perform
    deleted = PaperTrail::Version.where(['created_at <= ?', 3.months.ago]).destroy_all.count
    Rails.logger.info "#{deleted} old versions deleted."
  end
end
