class ContactUsMailer < ApplicationMailer

  default **get_defaults(
    name: Figaro.env.automation_task_from_name? ? Figaro.env.automation_task_from_name : 'OSMX Contact Us',
    mailname: Figaro.env.automation_task_from_mailname? ? Figaro.env.automation_task_from_mailname : 'contactus',
  )
  default to: Figaro.env.contact_us_to_address!

  def contact_form_submission(contact)
    @contact = contact
    mail ({
      :subject => build_subject("Contact Form Submission"),
      :reply_to => "\"#{@contact.name}\" <#{@contact.email_address}>"
    })
  end
end
