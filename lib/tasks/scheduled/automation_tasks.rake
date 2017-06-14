namespace :scheduled  do
  task :automation_tasks => :environment do
    $PROGRAM_NAME = "OSMX #{Rails.env} - Perform Automation Tasks"
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
    puts "Performing automation tasks"
    tasks = AutomationTask.where(active: true).order(:section_id)
    count = tasks.size
    count_length = count.to_s.length
    puts "\tNo tasks to perform" if count == 0
    tasks.each_with_index do |task, index|
      begin
        puts "\tDoing #{(index + 1).to_s.rjust(count_length, ' ')} of #{count} (id: #{task.id})"
        fail Osm::Forbidden unless task.has_permissions?
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
end
