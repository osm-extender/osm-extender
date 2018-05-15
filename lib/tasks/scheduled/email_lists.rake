namespace :scheduled  do
  desc "Check email lists for changes"
  task :email_lists => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Send Changed Email Lists"
    EmailListsJob.new.perform_now
    Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of EmailListsJob.'
  end
end
