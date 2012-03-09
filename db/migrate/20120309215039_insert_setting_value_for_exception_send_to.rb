class InsertSettingValueForExceptionSendTo < ActiveRecord::Migration

  def self.up
    unless Rails.env.test?
      SettingValue.create ([
        {
          :key => 'notifier mailer - send exception to',
          :value => self.prompt('What address should exception notifications be sent to')
        },
      ])
    end
  end

  def self.down
    unless Rails.env.test?
      SettingValue.find_by_key('notifier mailer - send exception to').delete
    end
  end


  private
  def self.prompt(question)
    STDOUT.puts "#{question}?"
    STDOUT.print "> "
    STDIN.gets.strip
  end

end
