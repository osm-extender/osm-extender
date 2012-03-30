class InsertSettingValueForMaxSettingsAge < ActiveRecord::Migration

  def self.up
    unless Rails.env.test?
      SettingValue.create ([
        {
          :key => 'maximum settings age',
          :value => self.prompt('For how long should the settings read from the database be used without being reloaded')
        },
      ])
    end
  end

  def self.down
    unless Rails.env.test?
      SettingValue.find_by_key('maximum settings age').delete
    end
  end


  private
  def self.prompt(question)
    STDOUT.puts "#{question}?"
    STDOUT.print "> "
    STDIN.gets.strip
  end

end
