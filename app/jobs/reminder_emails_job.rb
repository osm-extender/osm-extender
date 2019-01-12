class ReminderEmailsJob < ApplicationJob
  queue_as :default

  def perform
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
    reminders = EmailReminder.where(:send_on => Date.today.wday).order(:section_id)
    count = reminders.size
    Rails.logger.info "No emails to send" if reminders.none?
    reminders.each_with_index do |reminder, index|
      begin
        Rails.logger.info "Sending #{(index + 1)} of #{count} (#{reminder.id} for user #{reminder.user_id})"
        reminder.send_email

      rescue Osm::Forbidden => exception
        Rails.logger.error "(#{reminder.id} for user #{reminder.user_id}) User is fobidden from fetching data"
        forbidden_emails_sent[reminder.user_id] ||= []
        unless forbidden_emails_sent[reminder.user_id].include?(reminder.section_id)
          EmailReminderMailer.forbidden(reminder, exception).deliver_now
          forbidden_emails_sent[reminder.user_id].push reminder.section_id
        end

      rescue Osm::Error::NoCurrentTerm => exception
        Rails.logger.error "(#{reminder.id} for user #{reminder.user_id}) No current term for section #{reminder.section_id}."
        noterm_emails_sent[reminder.user_id] ||= []
        unless noterm_emails_sent[reminder.user_id].include?(reminder.section_id)
          EmailReminderMailer.no_current_term(reminder, exception).deliver_now
          noterm_emails_sent[reminder.user_id].push reminder.section_id
        end

      rescue => exception
        Rails.logger.error "(#{reminder.id} for user #{reminder.user_id}, section #{reminder.section_id}) #{exception.message}."
        Rollbar.error exception
        EmailReminderMailer.failed(reminder).deliver_now

      end
    end # each reminder
  end # def perform

end
