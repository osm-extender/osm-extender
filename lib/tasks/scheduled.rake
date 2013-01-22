namespace :scheduled  do

  def exception_raised(task, exception)
    puts "\t\tAn Exception was raised (#{exception.message})"
    NotifierMailer.rake_exception(task, exception).deliver unless Settings.read('notifier mailer - send exception to').blank?
  end

  desc "Delete old sessions"
  task :delete_old_sessions => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Delete old sessions"
    deleted = Session.delete_old_sessions.size
    puts "#{deleted} entries deleted."
  end

  desc "Gather statistics"
  task :statistics => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Gathering statistics"
    earliest = User.minimum(:created_at).to_date
    (earliest..Date.yesterday).each do |date|
      Statistics.create_or_retrieve_for_date date
    end
  end


  namespace :send do
    desc "Send the reminder emails"
    task :reminder_emails => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Send Reminder Emails"
      puts "Sending Reminder Emails"
      reminders = EmailReminder.where(:send_on => Date.today.wday).order('section_id')
      count = reminders.size
      count_length = count.to_s.length
      puts "\tNo emails to send" if count == 0
      reminders.each_with_index do |reminder, index|
        begin
          puts "\tSending #{(index + 1).to_s.rjust(count_length, ' ')} of #{count} (id: #{reminder.id})"
          reminder.send_email
        rescue Exception => exception
          exception_raised("Reminder Email (id: #{reminder.id})", exception)
        end
      end
    end
  
    desc "Check email lists for changes"
    task :changed_email_lists => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Send Changed Email Lists"
      puts "Checking for email lists with changed addresses"
      lists = EmailList.where(:notify_changed => true).order(:section_id)
      count = lists.size
      count_length = count.to_s.length
      puts "\tNo email lists to check" if count == 0
      lists.each_with_index do |list, index|
        puts "\tChecking #{(index + 1).to_s.rjust(count_length, ' ')} of #{count} (id: #{list.id})"
        begin
          todays_hash = list.get_hash_of_addresses
          unless todays_hash.eql?(list.last_hash_of_addresses)
            list.update_attributes(:last_hash_of_addresses => todays_hash)
            NotifierMailer.email_list_changed(list).deliver
          end
        rescue Exception => exception
          exception_raised("Checking list for changed address (id: #{list.id})", exception)
        end
      end
    end

    task :all => [:reminder_emails, :changed_email_lists]
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
