class ContactUsMailer < ApplicationMailer
  def contact_form_submission(contact)
    @contact = contact
    mail ({
      :subject => build_subject("Contact Form Submission"),
      :reply_to => "\"#{@contact.name}\" <#{@contact.email_address}>"
    })
  end
end
