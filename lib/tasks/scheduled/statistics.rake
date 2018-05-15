namespace :scheduled  do
  desc "Gather statistics"
  task :statistics => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Gathering statistics"
    CreateStatisticsJob.new.perform_now
    Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of CreateStatisticsJob.'
  end
end
