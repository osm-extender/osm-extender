class NotifierMailer < ActionMailer::Base
  default from: Settings.read('notifier mailer - from')

  def contact_form_submission(contact, to)
    @contact = contact
    mail ({
      :subject => build_subject("Contact Form Submission from \"#{@contact.name}\" <#{@contact.email_address}>"),
      :to => to
    })
  end

  def reminder_failed(email_reminder, exception)
    @email_reminder = email_reminder
    @exception = exception
    mail ({
      :subject => build_subject('Reminder Email Failed'),
      :to => Settings.read('reminder mailer - send failed to'),
    })
  end

  private
  def build_subject(subject)
    start = 'OSMExtender'
    start += " (#{Rails.env.upcase})" unless Rails.env.production?
    return "#{start} - #{subject}"
  end

end
