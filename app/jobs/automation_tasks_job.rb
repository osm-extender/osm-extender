class AutomationTasksJob < ActiveJob::Base
  queue_as :default

  def perform
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
    tasks = AutomationTask.where(active: true).order(:section_id)
    count = tasks.count

    if tasks.none?
      Rails.logger.info "No tasks to perform."
      return
    end

    tasks.each_with_index do |task, index|
      begin
        Rails.logger.info "Doing #{index+1} of #{count} (#{task.id} - #{task.class} for user #{task.user_id})"
        fail Osm::Forbidden unless task.has_permissions?
        ret_val = task.do_task

        unless ret_val[:success]
          AutomationTaskMailer.errors(task, ret_val[:errors]).deliver_now
        end

        rescue Osm::Forbidden => exception
          Rails.logger.error "(#{task.id} - #{task.class} for user #{task.user_id}) User is forbidden from fetching data."
          forbidden_emails_sent[task.user_id] ||= []
          unless forbidden_emails_sent[task.user_id].include?(task.section_id)
            AutomationTaskMailer.forbidden(task, exception).deliver_now
            forbidden_emails_sent[task.user_id].push task.section_id
          end

        rescue Osm::Error::NoCurrentTerm => exception
          Rails.logger.error "(#{task.id} - #{task.class} for user #{task.user_id}) No current term for section #{task.section_id}."
          noterm_emails_sent[task.user_id] ||= []
          unless noterm_emails_sent[task.user_id].include?(task.section_id)
            AutomationTaskMailer.no_current_term(task, exception).deliver_now
            noterm_emails_sent[task.user_id].push task.section_id
          end

        rescue => exception
          Rails.logger.error "(#{task.id} - #{task.class} for user #{task.user_id}, section #{task.section_id}) #{exception.message}."
          Rollbar.error exception

      end # begin
    end # each task
  end # def perform

end
