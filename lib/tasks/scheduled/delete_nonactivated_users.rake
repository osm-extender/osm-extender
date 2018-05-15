namespace :scheduled  do
  desc "Remove nonactivated users whose activation tokens have expired"
  task :delete_nonactivated_users => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Removing nonactivated users"
    PruneUnactivatedUsersJob.new.perform_now
    Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of PruneUnactivatedUsersJob.'
  end
end
