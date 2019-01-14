class RemoveSignupcodeSetting < ActiveRecord::Migration[4.2]
  def prompt(question, test_answer)
    return test_answer if Rails.env.test?
    STDOUT.puts question
    STDOUT.print "> "
    STDIN.gets.strip
  end
  class SettingValue < ActiveRecord::Base
    has_paper_trail
    validates_presence_of :key
    validates_uniqueness_of :key
    validates_presence_of :description
  end


  def up
    sv = SettingValue.find_by_key('signup code')
    sv.destroy unless sv.nil?
  end

  def down
    sv = SettingValue.find_or_create_by_key('signup code')
    sv.description = 'A code which must be supplied to create an account (useful for temporarily limiting signups). If this is blank then no signup code will be required.'
    sv.value = prompt('What signup code would you like to require users to use (if blank then no code will be asked for)', '') unless sv.persisted?
    sv.save!
  end
end
