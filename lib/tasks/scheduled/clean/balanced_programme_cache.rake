namespace :scheduled  do
  namespace :clean  do
    desc "Stop the balanced programme cache table getting too big"
    task :balanced_programme_cache => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Balanced Programme Cache"
      PruneBalancedProgrammeCacheJob.new.perform_now
      Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of PruneBalancedProgrammeCacheJob.'
    end
  end
end
