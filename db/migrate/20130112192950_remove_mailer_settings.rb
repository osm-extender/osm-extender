class RemoveMailerSettings < ActiveRecord::Migration
  def prompt(question, test_answer)
    return test_answer if Rails.env.test?
    STDOUT.puts question
    STDOUT.print "> "
    STDIN.gets.strip
  end

  def up
    setting_keys = ['Mail Server - Address', 'Mail Server - Port', 'Mail Server - Domain', 'Mail Server - Username', 'Mail Server - Password']
    setting_keys.each do |key|
      sv = SettingValue.find_by_key(key)
      sv.destroy unless sv.nil?
    end
  end

  def down
    settings = [
      {
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
      }
    ]
    settings.each do |setting|
      sv = SettingValue.find_or_create_by_key(setting[:key])
      sv.description = setting[:description]
      sv.value = setting[:value] || prompt(setting[:prompt], '') unless sv.persisted?
      sv.save!
    end
  end
end
