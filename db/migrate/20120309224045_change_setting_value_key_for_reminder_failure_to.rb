class ChangeSettingValueKeyForReminderFailureTo < ActiveRecord::Migration

  def self.up
    sv = SettingValue.find_by_key!('reminder mailer - send failed to')
    sv.key = 'notifier mailer - send failed reminder to'
    sv.save!
  end

  def self.down
    sv = SettingValue.find_by_key!('notifier mailer - send failed reminder to')
    sv.key = 'reminder mailer - send failed to'
    sv.save!
  end

end
