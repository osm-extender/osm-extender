namespace :scheduled  do
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
          EmailListMailer.changed(list).deliver_now
        end
      rescue Osm::Forbidden => exception
        puts "\t\tUser is fobidden from fetching data"
        forbidden_emails_sent[list.user_id] ||= []
        unless forbidden_emails_sent[list.user_id].include?(list.section_id)
          EmailListMailer.forbidden(list, exception).deliver_now
          forbidden_emails_sent[list.user_id].push list.section_id
        end
      rescue Osm::Error::NoCurrentTerm => exception
        puts "\t\tNo current term for section"
        noterm_emails_sent[list.user_id] ||= []
        unless noterm_emails_sent[list.user_id].include?(list.section_id)
          EmailListMailer.no_current_term(list, exception).deliver_now
          noterm_emails_sent[list.user_id].push list.section_id
        end
      rescue Exception => exception
        exception_raised("Checking list for changed address (id: #{list.id}, user: #{list.user_id}, section: #{list.section_id})", exception)
      end
    end
  end
end
