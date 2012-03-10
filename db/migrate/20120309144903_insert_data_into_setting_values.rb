class InsertDataIntoSettingValues < ActiveRecord::Migration

  def self.up
    unless Rails.env.test?
      SettingValue.create ([
      {
        :key => 'contact us - to',
        :value => self.prompt('What email address should contact us form submissions be sent to')
      }, {
        :key => 'notifier mailer - from',
        :value => self.prompt('What email address should notifier mails be sent from')
      }, {
        :key => 'user mailer - from',
        :value => self.prompt('What email address should user related mails be sent from')
      }, {
        :key => 'reminder mailer - from',
        :value => self.prompt('What email address should reminder mails be sent from')
      }, {
        :key => 'reminder mailer - send failed to',
        :value => self.prompt('What email address should reminder failure mails be sent to')
      }, {
        :key => 'OSM API - id',
        :value => self.prompt('What is the OSM API ID to use')
      }, {
        :key => 'OSM API - token',
        :value => self.prompt('What is the OSM API token to use')
      }, {
        :key => 'OSM API - name',
        :value => self.prompt('What is the name displayed on OSM\'s External Access tab for this API')
      }, {
        :key => 'ReCAPTCHA - public key',
        :value => self.prompt('What is the public key to use with ReCAPTCHA')
      }, {
        :key => 'ReCAPTCHA - private key',
        :value => self.prompt('What is the private key to use with ReCAPTCHA')
      }, {
        :key => 'Mail Server - Address',
        :value => self.prompt('What is the address of your SMTP server')
      }, {
        :key => 'Mail Server - Port',
        :value => self.prompt('What port on the SMTP server should be used')
      }, {
        :key => 'Mail Server - Domain',
        :value => self.prompt('What is your login domain on the SMTP server')
      }, {
        :key => 'Mail Server - Username',
        :value => self.prompt('What is your username on the SMTP server')
      }, {
        :key => 'Mail Server - Password',
        :value => self.prompt('What is your password on the SMTP server')
      }, {
        :key => 'signup code',
        :value => self.prompt('What signup code would you like to require users to use (if blank then no code will be asked for)')
      }
      ])
    end

    if Rails.env.development?
      SettingValue.create({
        :key => 'Mail Server - Development recipient',
        :value => prompt('Where should emails actually be sent to in the development environment')  
      })
    end
  end

  def self.down
    SettingValue.find_by_key('contact us - to').delete
    SettingValue.find_by_key('notifier mailer - from').delete
    SettingValue.find_by_key('user mailer - from').delete
    SettingValue.find_by_key('reminder mailer - from').delete
    SettingValue.find_by_key('reminder mailer - send failed to').delete
    SettingValue.find_by_key('OSM API - id').delete
    SettingValue.find_by_key('OSM API - token').delete
    SettingValue.find_by_key('OSM API - name').delete
    SettingValue.find_by_key('ReCAPTCHA - public key').delete
    SettingValue.find_by_key('ReCAPTCHA - private key').delete
    SettingValue.find_by_key('Mail Server - Address').delete
    SettingValue.find_by_key('Mail Server - Port').delete
    SettingValue.find_by_key('Mail Server - Domain').delete
    SettingValue.find_by_key('Mail Server - Username').delete
    SettingValue.find_by_key('Mail Server - Password').delete
    SettingValue.find_by_key('signup code').delete
  end


  private
  def self.prompt(question)
    STDOUT.puts "#{question}?"
    STDOUT.print "> "
    STDIN.gets.strip
  end
end
