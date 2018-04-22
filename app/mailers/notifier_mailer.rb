class NotifierMailer < ApplicationMailer
  def self.options=(options)
    fail ArgumentError 'options is not a Hash' unless options.is_a?(Hash)
    [:contact_form__to].each do |option|
      fail ArgumentError "options must contain a value for :#{option}" unless options.has_key?(option)
    end
    @@options = options
  end

  def contact_form_submission(contact)
    @contact = contact
    mail ({
      :subject => build_subject("Contact Form Submission"),
      :to => @@options[:contact_form__to],
      :reply_to => "\"#{@contact.name}\" <#{@contact.email_address}>"
    })
  end

end
