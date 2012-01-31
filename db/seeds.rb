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

Faq.create ([
  {
    :question => "What's Online Scout Manager Extender",
    :answer => "Online Scout Manager Extender is a site which provides extra features to the [Online Scout Manager](https://www.onlinescoutmanager.co.uk).",
    :active => true
  }, {
    :question => "Is it safe to give this site my Online Scout Manager password?",
    :answer => "Yes. Your email address and password are not stored on this site. They are used to confirm your identity to OSM in order to gain a user id and secret which are then used to access OSM on your behalf.",
    :active => true
  }, {
    :question => "I would like Online Scout Manager Extender to ...",
    :answer => "First consider suggesting the feature in the Online Scout Manager forum. If It's not taken or you feel it doesn't belong in OSM then use the Contact option to get in touch.",
    :active => true
  }, {
    :question => "What's the OSM Permissions page?",
    :answer => "This page displays a list of the permissions that various parts of this site need in order to do their job and tells you if you've correctly set them in OSM.",
    :active => true
  }, {
    :question => "What's the Email lists feature?",
    :answer => "The Email lists feature allows you to create a list of email addresses (which you can then copy-paste into your email). You can select which of the four email fields in OSM to include and some basic selection criteria.\n\nSimply tick off the email fields you'd like to get the email addresses from and use the drop down boxes to choose which email addresses to get. For example \"for members who are not in the leaders\" would give you all youth members.",
    :active => true
  }
]) unless Rails.env.test?


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
  }
])