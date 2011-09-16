def get_value(value_human, value_key)
  puts "\t#{value_human}?\t[#{@machine_configuration[value_key]}]"
  print "\t"
  response = gets.strip
  @machine_configuration[value_key] = response unless (response.size == 0)
end

require 'yaml'


puts 'Loading rails environment'
require File.join(File.dirname(__FILE__), 'config', 'application')
Rails.application.require_environment!


puts "Setting up machine configuration file (Rails.root/config/machine.yml)"
machine_configuration_file = File.join(Rails.root, 'config', 'machine.yml')
@machine_configuration = {}
if FileTest::exist?(machine_configuration_file)
  @machine_configuration = YAML.load_file(machine_configuration_file)
end

get_value('Mail server (address)', 'mailer_server')
get_value('Mail server (port)', 'mailer_port')
get_value('Mail server (domain)', 'mailer_domain')
get_value('Mail server (username)', 'mailer_username')
get_value('Mail server (password)', 'mailer_password')
get_value('Where to actually send emails in development mode', 'development_mail_interceptor_send_to')

file = File.open(machine_configuration_file, 'w')
file.write YAML.dump(@machine_configuration)
file.close


puts '' # Spacing
puts "Generating Developer Documentation"
system('bundle exec rake doc:app')


puts '' # Spacing
puts "Done"
puts "Remember to setup your database if this is your first time running this script\n"
puts "(bundle exec rake db:setup)"
