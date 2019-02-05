class PruneAnnouncementsJob < ApplicationJob
  queue_as :default

  def perform
    deleted = Announcement.where(['updated_at <= :when AND finish <= :when', when: 6.months.ago]).destroy_all.count
    Rails.logger.info "#{deleted} old announcements deleted."
  end
end
