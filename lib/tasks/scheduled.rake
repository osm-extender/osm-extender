namespace :scheduled  do

  desc "Delete old sessions"
  task :delete_old_sessions => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Delete old sessions"
    deleted = Session.delete_old_sessions.size
    puts "#{deleted} entries deleted."
  end

  desc "Send the reminder emails"
  task :send_reminder_emails => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Send Reminder Emails"
    reminders = EmailReminder.where(['send_on = ?', Date.today.wday]).order('section_id')
    count = reminders.size
    count_length = count.to_s.length
    puts "No emails to send" if count == 0
    reminders.each_with_index do |reminder, index|
      puts "Sending #{(index + 1).to_s.rjust(count_length, ' ')} of #{count} (id: #{reminder.id})"
      reminder.send_email
    end
  end

  desc "Gather statistics"
  task :statistics => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Gathering statistics"
    earliest = User.minimum(:created_at).to_date
    (earliest..Date.yesterday).each do |date|
      Statistics.create_or_retrieve_for_date date
    end
  end


  namespace :clean  do
    desc "Stop the balanced programme cache table getting too big"
    task :balanced_programme_cache => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Balanced Programme Cache"
      deleted = ProgrammeReviewBalancedCache.delete_old.size
      puts "#{deleted} programme review caches deleted."
    end
  
    desc "Stop the announcements tables getting too big"
    task :announcements => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Announcements"
      deleted = Announcement.delete_old.size
      puts "#{deleted} announcements deleted."
    end

    task :all => [:balanced_programme_cache, :announcements]
  end

end
