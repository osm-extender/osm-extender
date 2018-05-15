namespace :scheduled  do
  desc "Perform automation tasks"
  task :automation_tasks => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Perform Automation Tasks"
    AutomationTasksJob.new.perform_now
    Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of AutomationTasksJob.'
  end
end
