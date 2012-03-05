class ReminderMailer < ActionMailer::Base
  default from: Settings.read('reminder mailer - from')

  def reminder_email(user, section_name, data, configuration)
    @section_name = section_name
    @data = data
    @configuration = configuration
    mail ({
      :subject => build_subject("Reminder Email for #{@section_name}"),
      :to => "\"#{user.name}\" <#{user.email_address}>",
    })
  end

  def failed(email_reminder, section_name)
    @email_reminder = email_reminder
    @section_name = section_name
    mail ({
      :subject => build_subject("Reminder Email for #{@section_name} Failed"),
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
