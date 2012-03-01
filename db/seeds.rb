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
unless Rails.env.test?
  SettingValue.create ([
    {
      :key => 'contact us - to',
      :value => prompt('What email address should contact us form submissions be sent to')
    }, {
      :key => 'notifier mailer - from',
      :value => prompt('What email address should notifier mails be sent from')
    }, {
      :key => 'user mailer - from',
      :value => prompt('What email address should user related mails be sent from')
    }, {
      :key => 'reminder mailer - from',
      :value => prompt('What email address should reminder mails be sent from')
    }, {
      :key => 'reminder mailer - send failed to',
      :value => prompt('What email address should reminder failure mails be sent to')
    }, {
      :key => 'OSM API - id',
      :value => prompt('What is the OSM API ID to use')
    }, {
      :key => 'OSM API - token',
      :value => prompt('What is the OSM API token to use')
    }, {
      :key => 'OSM API - name',
      :value => prompt('What is the name displayed on OSM\'s External Access tab for this API')
    }, {
      :key => 'ReCAPTCHA - public key',
      :value => prompt('What is the public key to use with ReCAPTCHA')
    }, {
      :key => 'ReCAPTCHA - private key',
      :value => prompt('What is the private key to use with ReCAPTCHA')
    }, {
      :key => 'Mail Server - Address',
      :value => prompt('What is the address of your SMTP server')
    }, {
      :key => 'Mail Server - Port',
      :value => prompt('What port on the SMTP server should be used')
    }, {
      :key => 'Mail Server - Domain',
      :value => prompt('What is your login domain on the SMTP server')
    }, {
      :key => 'Mail Server - Username',
      :value => prompt('What is your username on the SMTP server')
    }, {
      :key => 'Mail Server - Password',
      :value => prompt('What is your password on the SMTP server')
    }
  ])
end


if Rails.env.development?
  SettingValue.create({
    :key => 'Mail Server - Development recipient',
    :value => prompt('Where should emails actually be sent to in the development environment')  
  })
end
