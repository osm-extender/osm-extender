puts
puts "Seeding data"
puts "------------"
puts "------------"
puts


# Method to prompt user for data
# param question - the question to ask the user
# param test_answer - the answer provided by the user in the test environment
def self.prompt(question, test_answer=nil)
  return test_answer if Rails.env.test?
  STDOUT.puts "#{question}?"
  STDOUT.print "> "
  STDIN.gets.strip
end



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
    :prompt => 'For how long should the settings read from the database be used without being reloaded',
    :key => 'maximum settings age',
    :description => "How long the site's settings should be kept in memory before rereading from the database. This should be a number followed by a unit of time e.g. '10 minutes' or '1 hour'",
  }
]
config.each do |setting|
  sv = SettingValue.find_or_create_by_key(setting[:key])
  sv.description = setting[:description]
  sv.value = prompt(setting[:prompt], (setting[:test_value] || sv.value))
  sv.save!
end
Settings.reread_settings
puts



#
# First User
#
unless User.count >= 1
  puts "Creating the first user account"
  puts "-------------------------------"
  User.create(
    :name => prompt('What is your name?', 'Alice'),
    :email_address => prompt('What is your email address?', 'alice@example.com'),
    :password => prompt('What would you like your password to be?', 'P@55word'),
    :activation_state => "active",
    :can_administer_users => true,
    :can_administer_settings => true,
    :can_view_statistics => true,
    :can_administer_announcements => true,
    :can_administer_delayed_job => true,
    :can_become_other_user => true,
  )
  puts
end


#SeedFu.seed(fixture_paths, filter) # Both argumants optional - github.com/mbleigh/seed-fu
