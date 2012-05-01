class ReminderMailer < ActionMailer::Base
  default from: Settings.read('reminder mailer - from')
  layout 'mail'

  def reminder_email(user, role, data)
    @data = data
    @role = role

    mail ({
      :subject => build_subject("Reminder Email for #{@role.long_name}"),
      :to => "\"#{user.name}\" <#{user.email_address}>",
    })
  end

  def failed(email_reminder, role)
    @email_reminder = email_reminder
    @role = role
    mail ({
      :subject => build_subject("Reminder Email for #{@role.long_name} Failed"),
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
