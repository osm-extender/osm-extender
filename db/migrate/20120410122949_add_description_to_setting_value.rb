class AddDescriptionToSettingValue < ActiveRecord::Migration

  def self.up
    add_column :setting_values, :description, :text, :null=>true

    SettingValue.reset_column_information
    unless Rails.env.test?
      data = {
        'contact us - to' => "Which email address submissions of the contact us form should be sent to.",
        'notifier mailer - from' => "Which email address notification messages should claim to be from.",
        'user mailer - from' => "Which email address user account messages should claim to be from.",
        'signup code' => "A code which must be supplied to create an account (useful for temporarily limiting signups). If this is blank then no signup code will be required.",
        'reminder mailer - from' => "Which email address reminder emails should claim to be from.",
        'notifier mailer - send failed reminder to' => "Which email address to send debugging information from failed email reminder messages to. If this is blank then this email will not be sent.",
        'OSM API - id' => "The ID you got from Ed at OSM",
        'OSM API - token' => "The token you got from Ed at OSM",
        'OSM API - name' => "The name your API has on OSM's External Access tab",
        'ReCAPTCHA - public key' => "The public key you got from ReCAPTCHA",
        'ReCAPTCHA - private key' => "The private key you got from ReCAPTCHA",
        'Mail Server - Address' => "The address of the SMTP server to use for outgoing email",
        'Mail Server - Port' => "The port of the SMTP server to use for outgoing email (this is normally 25)",
        'Mail Server - Domain' => "The login domain for the SMTP server to use for outgoing email",
        'Mail Server - Username' => "The login username for the SMTP server to use for outgoing email",
        'Mail Server - Password' => "The login password for the SMTP server to use for outgoing email",
        'maximum settings age' => "How long the site's settings should be kept in memory before rereading from the database. This should be a number followed by a unit of time e.g. '10 minutes' or '1 hour'",
        'notifier mailer - send exception to' => "Which email address should exceptions be sent to. If this is blank then this email will not be sent.",
      }
      data.each_key do |key|
        s = SettingValue.find_by_key(key)
        s.description = data[key]
        s.save!
      end
    end

    change_column :setting_values, :description, :text, :null=>false
    change_column :setting_values, :key, :string, :null=>false
  end

  def self.down
    remove_column :setting_values, :description
  end

end
