class DeleteInactiveUsers < ActiveRecord::Migration[4.2]
  def up
    ids = User.connection.execute(
      <<~HERE_DOC
        SELECT
          users.id
        FROM users
          LEFT JOIN automation_tasks ON users.id = automation_tasks.user_id
          LEFT JOIN email_reminders ON users.id = email_reminders.user_id
          LEFT JOIN email_lists ON users.id = email_lists.user_id
        WHERE
          users.gdpr_consent_at IS null
          AND automation_tasks.id IS null
          AND email_reminders.id IS null
          AND (email_lists.notify_changed IS null OR email_lists.notify_changed = false)
        ;
      HERE_DOC
    ).to_a.map { |v| v['id'] }

    ids.each_slice(50) do |batch_of_ids|
      User.where(id: batch_of_ids)
          .each(&:destroy)
    end
  end

  def down
  end
end
