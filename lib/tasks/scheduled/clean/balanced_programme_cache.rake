namespace :scheduled  do
  namespace :clean  do
    desc "Stop the balanced programme cache table getting too big"
    task :balanced_programme_cache => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Balanced Programme Cache"
      deleted = ProgrammeReviewBalancedCache.delete_old.size
      puts "#{deleted} programme review caches deleted."
    end
  end
end
