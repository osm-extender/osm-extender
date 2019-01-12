class PruneAnnouncementsJob < ApplicationJob
  queue_as :default

  def perform
    deleted = Announcement.destroy_all(['updated_at <= :when AND finish <= :when', when: 6.months.ago]).count
    Rails.logger.info "#{deleted} old announcements deleted."
  end
end
