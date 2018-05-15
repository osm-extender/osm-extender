namespace :scheduled  do
  namespace :clean  do
    desc "Stop the versions tables getting too big"
    task :paper_trails => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Paper Trails"
      PrunePaperTrailsJob.new.perform_now
      Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of PrunePaperTrailsJob.'
    end
  end
end
