namespace :scheduled  do
  namespace :clean  do
    desc "Stop the announcements tables getting too big"
    task :announcements => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Announcements"
      PruneAnnouncementsJob.new.perform_now
      Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of PruneAnnouncementsJob.'
    end
  end
end
