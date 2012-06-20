puts
puts "Seeding data"
puts "------------"
puts "------------"
puts

SeedFu.quiet = true


# Method to prompt user for data
# param question - the question to ask the user
# param test_answer - the answer provided by the user in the test environment
def self.prompt(question, test_answer)
  return test_answer if Rails.env.test?
  STDOUT.puts question
  STDOUT.print "> "
  STDIN.gets.strip
end


#
# First User
#
unless User.where(['id = ?', 1]).size == 1
  puts "Creating the first user account"
  puts "-------------------------------"
  User.seed(:id) do |u|
    u.id = 1
    u.name = prompt('What is your name?', 'Alice')
    u.email_address = prompt('What is your email address?', 'alice@example.com')
    u.password = prompt('What would you like your password to be?', 'P@55word')
    u.activation_state = "active"
    u.can_administer_users = true
    u.can_administer_faqs = true
    u.can_administer_settings = true
    u.can_view_statistics = true
  end
  puts
end


#
# FAQs
#
puts "Creating FAQs"
puts "-------------"
faq_tag_osmx = FaqTag.find_or_create_by_name('Online Scout Manager Extender')
faq_tag_features = FaqTag.find_or_create_by_name('Features')
Faq.seed(:system_id,
  {
    :system_id => 1,
    :question => "What's Online Scout Manager Extender?",
    :answer => "Online Scout Manager Extender is a site which provides extra features to the [Online Scout Manager](https://www.onlinescoutmanager.co.uk).",
    :tags => [faq_tag_osmx],
    :active => true
  },{
    :system_id => 2,
    :question => "Is it safe to give this site my Online Scout Manager password?",
    :answer => "Yes. Your email address and password are not stored on this site. They are used to confirm your identity to OSM in order to gain a user id and secret which are then used to access OSM on your behalf.",
    :tags => [faq_tag_osmx],
    :active => true
  },{
    :system_id => 3,
    :question => "I would like Online Scout Manager Extender to ...",
    :answer => "First consider suggesting the feature in the Online Scout Manager forum. If It's not taken or you feel it doesn't belong in OSM then use the Contact option to get in touch.",
    :tags => [faq_tag_osmx],
    :active => true
  },{
    :system_id => 4,
    :question => "What's the OSM permissions page?",
    :answer => "This page displays a list of the permissions that various parts of this site need in order to do their job and tells you if you've correctly set them in OSM.",
    :tags => [faq_tag_features],
    :active => true
  },{
    :system_id => 5,
    :question => "What's the Email lists feature?",
    :answer => "The Email lists feature allows you to create a list of email addresses (which you can then copy-paste into your email). You can select which of the four email fields in OSM to include and some basic selection criteria.\n\nSimply tick off the email fields you'd like to get the email addresses from and use the drop down boxes to choose which email addresses to get. For example \"for members who are not in the leaders\" would give you all youth members.\n\nAfter retreiving the list of email addresses you'll be able to save the list for future reuse. Saving the list saves the criteria used for generating it, not the actual email addresses.",
    :tags => [faq_tag_features],
    :active => true
  },{ :system_id => 6,
    :question => "What's the Programme review feature?",
    :answer => "The Programme review feature allows you to easily discover how balanced your programme is. It does this by using the tags for each activity to count how many times your programme meets each zone and method.",
    :tags => [faq_tag_features],
    :active => true
  },{
    :system_id => 7,
    :question => "What's the Email reminder feature?",
    :answer => "The email reminder feature is designed to send you a weekly email of things you should be aware of, it is customisable - you get to choose what items appear and how far back/forwrd they look. In order to get started follow the links into the Email reminders area and to create a new reminder. Once you have created your reminder you'll need to add some items to it (otherwise you'll get a blank email each week). The availible items are:\n\n* Birthdays - Members of your section who have either just had or are about to have a birthday, you can customise from how far in the past to how far in the future birthdays are shown for.\n* Badges due - Displays a list of what badges each member is due.\n* Programme - Lists the programme (and activities) for the next few weeks, you can customise how many weeks ahead it looks.\n* Events - Lists the events coming up in the next few months, you can customise how many months ahead it looks.\n* Members not seen - Displays the members who have not been marked present for the last few weeks, you can customise how many weeks behind it looks.\n* Section notepad - Displays the contents of OSM's notepad for the section.",
    :tags => [faq_tag_features],
    :active => true
  },{
    :system_id => 8,
    :question => "What's the Programme wizard feature?",
    :answer => "The programme wizard feature allows you create a number of evenings with a specified title and start/end times easily. You specify the start date, end date and how many days should be between each meeting, along with the meeting title, start time and end time - OSMX does the rest.",
    :tags => [faq_tag_features],
    :active => true
  },
)
puts


#
# Setting Values
#
puts "Configuring OSMX"
puts "----------------"
SettingValue.seed(:key,
  {
    :key => 'contact us - to',
    :value => prompt('What email address should contact us form submissions be sent to', 'contactus@example.com'),
    :description => 'Which email address submissions of the contact us form should be sent to.',
  },{
    :key => 'notifier mailer - from',
    :value => prompt('What email address should notifier mails be sent from', 'notifier-mailer@example.com'),
    :description => 'Which email address notification messages should claim to be from.',
  },{
    :key => 'user mailer - from',
    :value => prompt('What email address should user related mails be sent from', 'user-mailer@example.com'),
    :description => 'Which email address user account messages should claim to be from.',
  },{
    :key => 'reminder mailer - from',
    :value => prompt('What email address should reminder mails be sent from', 'reminder-mailer@example.com'),
    :description => 'Which email address reminder emails should claim to be from',
  },{
    :key => 'notifier mailer - send failed reminder to',
    :value => prompt('What email address should reminder failure mails be sent to', 'reminder-mailer-failed@example.com'),
    :description => 'Which email address to send debugging information from failed email reminder messages to',
  },{
    :key => 'notifier mailer - send exception to',
    :value => self.prompt('What address should exception notifications be sent to', 'exceptions@example.com'),
    :description => 'Which email address should exceptions be sent to. If this is blank then this email will not be sent.',
  },{
    :key => 'OSM API - id',
    :value => prompt('What is the OSM API ID to use', '12'),
    :description => 'The ID you got from Ed at OSM.',
  },{
    :key => 'OSM API - token',
    :value => prompt('What is the OSM API token to use', '1234567890'),
    :description => 'The token you got from Ed at OSM.',
  },{
    :key => 'OSM API - name',
    :value => prompt('What is the name displayed on OSM\'s External Access tab for this API', 'Example API'),
    :description => "The name your API has on OSM's External Access tab.",
  },{
    :key => 'ReCAPTCHA - public key',
    :value => prompt('What is the public key to use with ReCAPTCHA', '11223344556677889900'),
    :description => 'The public key you got from ReCAPTCHA.',
  },{
    :key => 'ReCAPTCHA - private key',
    :value => prompt('What is the private key to use with ReCAPTCHA', '00998877665544332211'),
    :description => 'The private key you got from ReCAPTCHA.',
  },{
    :key => 'Mail Server - Address',
    :value => prompt('What is the address of your SMTP server', 'smtp.example.com'),
    :description => 'The address of the SMTP server to use for outgoing email.',
  },{
    :key => 'Mail Server - Port',
    :value => prompt('What port on the SMTP server should be used', '25'),
    :description => 'The port of the SMTP server to use for outgoing email (this is normally 25).',
  },{
    :key => 'Mail Server - Domain',
    :value => prompt('What is your login domain on the SMTP server', ''),
    :description => 'The login domain for the SMTP server to use for outgoing email.',
  },{
    :key => 'Mail Server - Username',
    :value => prompt('What is your username on the SMTP server', 'sender@example.com'),
    :description => 'The login username for the SMTP server to use for outgoing email.',
  },{
    :key => 'Mail Server - Password',
    :value => prompt('What is your password on the SMTP server', 'abcd1234'),
    :description => 'The login password for the SMTP server to use for outgoing email.',
  },{
    :key => 'signup code',
    :value => prompt('What signup code would you like to require users to use (if blank then no code will be asked for)', ''),
    :description => 'A code which must be supplied to create an account (useful for temporarily limiting signups). If this is blank then no signup code will be required.',
  },{
    :key => 'maximum settings age',
    :value => self.prompt('For how long should the settings read from the database be used without being reloaded', '1 second'),
    :description => "How long the site's settings should be kept in memory before rereading from the database. This should be a number followed by a unit of time e.g. '10 minutes' or '1 hour'",
  },
)
if Rails.env.test?
  SettingValue.seed(:key,
    {
      :key => 'test',
      :value => 'a1b2c3d4',
      :description => 'A test value.'
    }
  )
end
puts


#SeedFu.seed(fixture_paths, filter) # Both argumants optional - github.com/mbleigh/seed-fu