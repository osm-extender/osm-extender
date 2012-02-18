def prompt(question)
  puts "\t#{question}?"
  print "> "
  gets.strip
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

SettingValue.create ([
  {
    :key => 'contact us - to',
    :value => Rails.env.test? ? 'contactus@example.com' : prompt('What email address should contact us form submissions be sent to?')
  }, {
    :key => 'notifier mailer - from',
    :value => Rails.env.test? ? 'notifier-mailer@example.com' : prompt('What email address should notifier mails be sent from?')
  }, {
    :key => 'user mailer - from',
    :value => Rails.env.test? ? 'user-mailer@example.com' : prompt('What email address should user related mails be sent from?')
  }, {
    :key => 'reminder mailer - from',
    :value => Rails.env.test? ? 'reminder-mailer@example.com' : prompt('What email address should reminder mails be sent from?')
  }, {
    :key => 'reminder mailer - send failed to',
    :value => Rails.env.test? ? 'reminder-mailer-to@example.com' : prompt('What email address should reminder failure mails be sent to?')
  }
])