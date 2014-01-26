class RemoveMailerAddressSettings < ActiveRecord::Migration
  def prompt(question, test_answer)
    return test_answer if Rails.env.test?
    STDOUT.puts question
    STDOUT.print "> "
    STDIN.gets.strip
  end

  def up
    setting_keys = ['contact us - to', 'notifier mailer - from', 'user mailer - from', 'reminder mailer - from', 'notifier mailer - send failed reminder to', 'notifier mailer - send exception to']
    setting_keys.each do |key|
      sv = SettingValue.find_by_key(key)
      sv.destroy unless sv.nil?
    end
  end

  def down
    settings = [
      {
        :prompt => 'What email address should contact us form submissions be sent to',
        :key => 'contact us - to',
        :description => 'Which email address submissions of the contact us form should be sent to.',
      },{
        :prompt => 'What email address should notifier mails be sent from',
        :key => 'notifier mailer - from',
        :description => 'Which email address notification messages should claim to be from.',
      },{
        :prompt => 'What email address should user related mails be sent from',
        :key => 'user mailer - from',
        :description => 'Which email address user account messages should claim to be from.',
        :test_value => 'user-mailer@example.com',
      },{
        :prompt => 'What email address should reminder mails be sent from',
        :key => 'reminder mailer - from',
        :description => 'Which email address reminder emails should claim to be from',
      },{
        :prompt => 'What email address should reminder failure mails be sent to',
        :key => 'notifier mailer - send failed reminder to',
        :description => 'Which email address to send debugging information from failed email reminder messages to',
      },{
        :prompt => 'What address should exception notifications be sent to',
        :key => 'notifier mailer - send exception to',
        :description => 'Which email address should exceptions be sent to. If this is blank then this email will not be sent.',
      },{
        :prompt => 'For how long should the settings read from the database be used without being reloaded',
        :key => 'maximum settings age',
        :description => "How long the site's settings should be kept in memory before rereading from the database. This should be a number followed by a unit of time e.g. '10 minutes' or '1 hour'",
      }
    ]
    settings.each do |setting|
      sv = SettingValue.find_or_create_by_key(setting[:key])
      sv.description = setting[:description]
      sv.value = setting[:value] || prompt(setting[:prompt], '') unless sv.persisted?
      sv.save!
    end
  end
end
