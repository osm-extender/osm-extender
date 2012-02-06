namespace :scheduled  do

  desc "Stop the balanced programme cache table getting too big"
  task :clean_balanced_programme_cache => :environment do
    deleted = ProgrammeReviewBalancedCache.delete_old
    puts "#{deleted.size} entries deleted."
  end

end