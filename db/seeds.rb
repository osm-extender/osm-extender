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
