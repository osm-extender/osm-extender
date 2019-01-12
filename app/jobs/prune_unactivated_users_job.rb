class PruneUnactivatedUsersJob < ApplicationJob
  queue_as :default

  def perform
    deleted = User.activation_expired.destroy_all.count
    Rails.logger.info "#{deleted} activation expired users deleted."
  end
end
