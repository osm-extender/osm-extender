namespace :scheduled  do
  desc "Send the reminder emails"
  task :reminder_emails => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Send Reminder Emails"
    ReminderEmailsJob.new.perform_now
    Rails.logger.warn '[DEPRECATION] This rake task has been deprecated in favor of ReminderEmailsJob.'
  end
end
