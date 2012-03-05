class ReminderMailer < ActionMailer::Base
  default from: Settings.read('reminder mailer - from')

  def reminder_email(user, data, configuration)
    @data = data
    @configuration = configuration
    mail ({
      :subject => build_subject('Reminder Email'),
      :to => "\"#{user.name}\" <#{user.email_address}>",
    })
  end

  def failed(email_reminder)
    @email_reminder = email_reminder
    mail ({
      :subject => build_subject('Reminder Email Failed'),
      :to => "\"#{@email_reminder.user.name}\" <#{@email_reminder.user.email_address}>",
    })
  end


  private
  def build_subject(subject)
    start = 'OSMExtender'
    start += " (#{Rails.env.upcase})" unless Rails.env.production?
    return "#{start} - #{subject}"
  end

end
