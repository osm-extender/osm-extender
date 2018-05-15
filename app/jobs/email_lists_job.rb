class EmailListsJob < ActiveJob::Base
  queue_as :default

  def perform
    noterm_emails_sent = {}
    forbidden_emails_sent = {}
    lists = EmailList.where(:notify_changed => true).order(:section_id)
    count = lists.count
    Rails.logger.info 'No email lists to check' if lists.none?
    lists.each_with_index do |list, index|
      Rails.logger.info "Checking #{(index+1)} of #{count} (#{list.id} for user #{list.user_id})"
      begin
        todays_hash = list.get_hash_of_addresses
        next if todays_hash.eql?(list.last_hash_of_addresses)
        list.update_attributes(:last_hash_of_addresses => todays_hash)
        EmailListMailer.changed(list).deliver_now

      rescue Osm::Forbidden => exception
        Rails.logger.error "(#{list.id} for user #{list.user_id}) User is forbidden from fetching data."
        forbidden_emails_sent[list.user_id] ||= []
        unless forbidden_emails_sent[list.user_id].include?(list.section_id)
          EmailListMailer.forbidden(list, exception).deliver_now
          forbidden_emails_sent[list.user_id].push list.section_id
        end

      rescue Osm::Error::NoCurrentTerm => exception
        Rails.logger.error "(#{list.id} for user #{list.user_id}) No current term for section #{list.section_id}."
        noterm_emails_sent[list.user_id] ||= []
        unless noterm_emails_sent[list.user_id].include?(list.section_id)
          EmailListMailer.no_current_term(list, exception).deliver_now
          noterm_emails_sent[list.user_id].push list.section_id
        end

      rescue => exception
        Rails.logger.error "(#{list.id} for user #{list.user_id}, section #{list.section_id}) #{exception.message}."
        Rollbar.error exception

      end
    end # each list
  end # def perform

end
