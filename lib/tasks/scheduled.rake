namespace :scheduled  do

  desc "Stop the balanced programme cache table getting too big"
  task :clean_balanced_programme_cache => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Balanced Programme Cache"
    deleted = ProgrammeReviewBalancedCache.delete_old
    puts "#{deleted.size} entries deleted."
  end

  desc "Send the reminder emails"
  task :send_reminder_emails => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Send Reminder Emails"
    reminders = EmailReminder.where(['send_on = ?', Date.today.wday])
    count = reminders.size
    puts "No emails to send" if count == 0
    reminders.each_with_index do |reminder, index|
      $PROGRAM_NAME = "OSMX #{Rails.env} - Sending Reminder Email (#{index + 1} of #{count})"
      puts "Sending #{index + 1} of #{count}"
      reminder.send_email
    end
    $PROGRAM_NAME = "OSMX #{Rails.env} - Sent Reminder Emails"
  end
end