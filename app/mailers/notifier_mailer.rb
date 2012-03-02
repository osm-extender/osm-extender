class NotifierMailer < ActionMailer::Base
  default from: Settings.read('notifier mailer - from')

  def contact_form_submission(contact, to)
    @contact = contact
    mail ({
      :subject => build_subject("Contact Form Submission from \"#{@contact.name}\" <#{@contact.email_address}>),
      :to => to
    })
  end


  private
  def build_subject(subject)
    start = 'OSMExtender'
    start += " (#{Rails.env.upcase})" unless Rails.env.production?
    return "#{start} - #{subject}"
  end

end
