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
faq_tag_er = FaqTag.find_or_create_by_name('Email reminders')
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
    :tags => [faq_tag_features, faq_tag_er],
    :active => true
  },{
    :system_id => 8,
    :question => "What's the Programme wizard feature?",
    :answer => "The programme wizard feature allows you create a number of evenings with a specified title and start/end times easily. You specify the start date, end date and how many days should be between each meeting, along with the meeting title, start time and end time - OSMX does the rest.",
    :tags => [faq_tag_features],
    :active => true
  },{
    :system_id => 9,
    :question => "What's the Map members feature?",
    :answer => "The map members feature allows you to see a map depicting how your members are distributed. You can specify which address is used as well as what colour pin to use for each of your groupings, if you have a grouping named with one of the available colours then that colour should be picked for you. You can optionally enter the address of your meeting place for inclusion on the map (it is shown by a light green pin with a star inside). If more than one member lives at the same address then the number of members at that address appears in the pin. If the pin is light blue then the members at a shared address are not in the same grouping.\n\nThe location of the addresses are gathered from Google's geocoding service, the minimum detail the address needs should be streey address and either town or postcode (e.g. '12 Some Street, Some town' or '123 Some Lane, AB34 5FG').",
    :tags => [faq_tag_features],
    :active => true
  },{
    :system_id => 10,
    :question => "How can I share my email reminder with other leaders?",
    :answer => "Visit the  Email reminders page and you'll have a [Sharing] option in the actions column of the table. Clicking this allows you to view the people you have shared the reminder with, you can use the last row of the table to add new people. When a new person is added they will receive an email containing a link which they need to follow in order to subscribe to the reminder.",
    :tags => [faq_tag_er],
    :active => true
  },{
    :system_id => 11,
    :question => "How can I change my subscription to an email reminder?",
    :answer => "Every time you receive a reminder email or change your subscription state the email will contain a link to follow in order to do this. Additionally if you are an OSMX user you'll be able to edit your subscription to any reminder which has been shared with you by going to the Email reminders page.",
    :tags => [faq_tag_er],
    :active => true
  },
)
puts


#
# Setting Values
#
puts "Configuring OSMX"
puts "----------------"
config = [
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
    :prompt => 'What is the OSM API ID to use',
    :key => 'OSM API - id',
    :description => 'The ID you got from Ed at OSM.',
  },{
    :prompt => 'What is the OSM API token to use',
    :key => 'OSM API - token',
    :description => 'The token you got from Ed at OSM.',
  },{
    :prompt => 'What is the name displayed on OSM\'s External Access tab for this API',
    :key => 'OSM API - name',
    :description => "The name your API has on OSM's External Access tab.",
  },{
    :prompt => 'What is the public key to use with ReCAPTCHA',
    :key => 'ReCAPTCHA - public key',
    :description => 'The public key you got from ReCAPTCHA.',
  },{
    :prompt => 'What is the private key to use with ReCAPTCHA',
    :key => 'ReCAPTCHA - private key',
    :description => 'The private key you got from ReCAPTCHA.',
  },{
    :prompt => 'What is the address of your SMTP server',
    :key => 'Mail Server - Address',
    :description => 'The address of the SMTP server to use for outgoing email.',
  },{
    :prompt => 'What port on the SMTP server should be used',
    :key => 'Mail Server - Port',
    :description => 'The port of the SMTP server to use for outgoing email (this is normally 25).',
  },{
    :prompt => 'What is your login domain on the SMTP server',
    :key => 'Mail Server - Domain',
    :description => 'The login domain for the SMTP server to use for outgoing email.',
  },{
    :prompt => 'What is your username on the SMTP server',
    :key => 'Mail Server - Username',
    :description => 'The login username for the SMTP server to use for outgoing email.',
  },{
    :prompt => 'What is your password on the SMTP server',
    :key => 'Mail Server - Password',
    :description => 'The login password for the SMTP server to use for outgoing email.',
  },{
    :prompt => 'What signup code would you like to require users to use (if blank then no code will be asked for)',
    :key => 'signup code',
    :description => 'A code which must be supplied to create an account (useful for temporarily limiting signups). If this is blank then no signup code will be required.',
  },{
    :prompt => 'For how long should the settings read from the database be used without being reloaded',
    :key => 'maximum settings age',
    :description => "How long the site's settings should be kept in memory before rereading from the database. This should be a number followed by a unit of time e.g. '10 minutes' or '1 hour'",
  }
]
config.each do |setting|
  sv = SettingValue.find_or_create_by_key(setting[:key])
  sv.description = setting[:description]
  sv.value = setting[:value] || prompt(setting[:prompt], '') unless sv.persisted?
  sv.save!
end
puts


#SeedFu.seed(fixture_paths, filter) # Both argumants optional - github.com/mbleigh/seed-fu