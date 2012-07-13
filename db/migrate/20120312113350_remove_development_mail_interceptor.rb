class RemoveDevelopmentMailInterceptor < ActiveRecord::Migration

  def self.up
    if Rails.env.development?
      SettingValue.find_by_key('Mail Server - Development recipient').delete
    end
  end

  def self.down
    if Rails.env.development?
      SettingValue.create ([
        {
          :key => 'Mail Server - Development recipient',
          :value => self.prompt('Where should emails actually be sent to in the development environment')
        },
      ])
    end
  end


  private
  def self.prompt(question)
    STDOUT.puts "#{question}?"
    STDOUT.print "> "
    STDIN.gets.strip
  end

end