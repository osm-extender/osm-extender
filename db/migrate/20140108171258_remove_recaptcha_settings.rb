class RemoveRecaptchaSettings < ActiveRecord::Migration
  def prompt(question, test_answer)
    return test_answer if Rails.env.test?
    STDOUT.puts question
    STDOUT.print "> "
    STDIN.gets.strip
  end

  def up
    setting_keys = ['ReCAPTCHA - public key', 'ReCAPTCHA - private key']
    setting_keys.each do |key|
      sv = SettingValue.find_by_key(key)
      sv.destroy unless sv.nil?
    end
  end

  def down
    settings = [
      {
        :prompt => 'What is the public key to use with ReCAPTCHA',
        :key => 'ReCAPTCHA - public key',
        :description => 'The public key you got from ReCAPTCHA.',
      },{
        :prompt => 'What is the private key to use with ReCAPTCHA',
        :key => 'ReCAPTCHA - private key',
        :description => 'The private key you got from ReCAPTCHA.',
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
