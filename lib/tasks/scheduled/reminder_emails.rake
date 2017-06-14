namespace :scheduled  do
  desc "Send the reminder emails"
  task :reminder_emails => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Send Reminder Emails"
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
    puts "Sending reminder emails"
    reminders = EmailReminder.where(:send_on => Date.today.wday).order(:section_id)
    count = reminders.size
    count_length = count.to_s.length
    puts "\tNo emails to send" if count == 0
    reminders.each_with_index do |reminder, index|
      begin
        puts "\tSending #{(index + 1).to_s.rjust(count_length, ' ')} of #{count} (id: #{reminder.id})"
        reminder.send_email
      rescue Osm::Forbidden => exception
        puts "\t\tUser is fobidden from fetching data"
        forbidden_emails_sent[reminder.user_id] ||= []
        unless forbidden_emails_sent[reminder.user_id].include?(reminder.section_id)
          EmailReminderMailer.forbidden(reminder, exception).deliver_now
          forbidden_emails_sent[reminder.user_id].push reminder.section_id
        end
      rescue Osm::Error::NoCurrentTerm => exception
        puts "\t\tNo current term for section"
        noterm_emails_sent[reminder.user_id] ||= []
        unless noterm_emails_sent[reminder.user_id].include?(reminder.section_id)
          EmailReminderMailer.no_current_term(reminder, exception).deliver_now
          noterm_emails_sent[reminder.user_id].push reminder.section_id
        end
      rescue Exception => exception
        exception_raised("Reminder Email (id: #{reminder.id}, user: #{reminder.user_id}, section: #{reminder.section_id})", exception)
      end
    end
  end
end
