namespace :scheduled  do

  def exception_raised(task, exception)
    puts "\t\tAn Exception was raised (#{exception.message})"
    NotifierMailer.rake_exception(task, exception).deliver_now
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


  task :automation_tasks => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Perform Automation Tasks"
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
    puts "Performing Automation Tasks"
    tasks = AutomationTask.where(active: true).order('section_id')
    count = tasks.size
    count_length = count.to_s.length
    puts "\tNo tasks to perform" if count == 0
    tasks.each_with_index do |task, index|
      begin
        puts "\tDoing #{(index + 1).to_s.rjust(count_length, ' ')} of #{count} (id: #{task.id})"
        raise Osm::Forbidden unless task.has_permissions?
        ret_val = task.do_task
        unless ret_val[:success]
          AutomationTaskMailer.errors(task, ret_val[:errors]).deliver_now
        end
        rescue Osm::Forbidden => exception
          puts "\t\tUser is fobidden from fetching data"
          forbidden_emails_sent[task.user_id] ||= []
          unless forbidden_emails_sent[task.user_id].include?(task.section_id)
            AutomationTaskMailer.forbidden(task, exception).deliver_now
            forbidden_emails_sent[task.user_id].push task.section_id
          end
        rescue Osm::Error::NoCurrentTerm => exception
          puts "\t\tNo current term for section"
          noterm_emails_sent[task.user_id] ||= []
          unless noterm_emails_sent[task.user_id].include?(task.section_id)
            AutomationTaskMailer.no_current_term(task, exception).deliver_now
            noterm_emails_sent[task.user_id].push task.section_id
          end
        rescue Exception => exception
          exception_raised("Automation Task (id: #{task.id}, user: #{task.user_id}, section: #{task.section_id})", exception)
      end
    end
  end


  desc "Send the reminder emails"
  task :reminder_emails => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Send Reminder Emails"
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
    puts "Sending Reminder Emails"
    reminders = EmailReminder.where(:send_on => Date.today.wday).order('section_id')
    count = reminders.size
    count_length = count.to_s.length
    puts "\tNo emails to send" if count == 0
    reminders.each_with_index do |reminder, index|
      begin
        puts "\tSending #{(index + 1).to_s.rjust(count_length, ' ')} of #{count} (id: #{reminder.id})"
        reminder.send_email
      rescue Osm::Forbidden => exception
        puts "\t\tUser is fobidden from fetching data"
        forbidden_emails_sent[list.user_id] ||= []
        unless forbidden_emails_sent[list.user_id].include?(list.section_id)
          NotifierMailer.forbidden(list, exception).deliver_now
          forbidden_emails_sent[list.user_id].push list.section_id
        end
      rescue Osm::Error::NoCurrentTerm => exception
        puts "\t\tNo current term for section"
        noterm_emails_sent[list.user_id] ||= []
        unless noterm_emails_sent[list.user_id].include?(list.section_id)
          NotifierMailer.no_current_term(list, exception).deliver_now
          noterm_emails_sent[list.user_id].push list.section_id
        end
      rescue Exception => exception
        exception_raised("Reminder Email (id: #{reminder.id}, user: #{reminder.user_id}, section: #{reminder.section_id})", exception)
      end
    end
  end


  desc "Check email lists for changes"
  task :email_lists => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Send Changed Email Lists"
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
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
          NotifierMailer.email_list_changed(list).deliver_now
        end
      rescue Osm::Forbidden => exception
        puts "\t\tUser is fobidden from fetching data"
        forbidden_emails_sent[list.user_id] ||= []
        unless forbidden_emails_sent[list.user_id].include?(list.section_id)
          NotifierMailer.email_list_changed__forbidden(list, exception).deliver_now
          forbidden_emails_sent[list.user_id].push list.section_id
        end
      rescue Osm::Error::NoCurrentTerm => exception
        puts "\t\tNo current term for section"
        noterm_emails_sent[list.user_id] ||= []
        unless noterm_emails_sent[list.user_id].include?(list.section_id)
          NotifierMailer.email_list_changed__no_current_term(list, exception).deliver_now
          noterm_emails_sent[list.user_id].push list.section_id
        end
      rescue Exception => exception
        puts "\t\tAn Exception was raised (#{exception.message})"
        exception_raised("Checking list for changed address (id: #{list.id}, user: #{list.user_id}, section: #{list.section_id})", exception)
      end
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

    desc "Stop the versions tables getting too big"
    task :paper_trails => :environment do
      $PROGRAM_NAME = "OSMX #{Rails.env} - Clean Paper Trails"
      deleted = 0
      [PaperTrail::Version, UserVersion].each do |model|
        this_deleted = model.destroy_all(["created_at < ?", 1.year.ago]).size
        puts "deleted #{this_deleted} old #{model.name} versions."
        deleted += this_deleted
      end
      puts "deleted #{deleted} total old versions."
    end

    task :all => [:balanced_programme_cache, :announcements, :paper_trails]
  end

  task :monthly => ['clean:all']
  task :daily => [:automation_tasks, :reminder_emails, :email_lists, :statistics]
  task :hourly => [:delete_old_sessions]

end
