class CreateStatisticsJob < ActiveJob::Base
  queue_as :default

  def perform
    earliest = User.minimum(:created_at).to_date
    existing = Statistics.pluck(:date)
    (earliest..Date.yesterday).each do |date|
      next if existing.include?(date)
      Statistics.create_or_retrieve_for_date date
      Rails.logger.info "created statistics for #{date}."
    end
  end
end
