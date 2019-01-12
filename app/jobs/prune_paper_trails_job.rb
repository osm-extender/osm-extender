class PrunePaperTrailsJob < ApplicationJob
  queue_as :default

  def perform
    deleted = PaperTrail::Version.destroy_all(['created_at <= ?', 3.months.ago]).count
    Rails.logger.info "#{deleted} old versions deleted."
  end
end
