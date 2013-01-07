class NotifierMailer < ApplicationMailer
  default from: Proc.new { Settings.read('notifier mailer - from') },
          'return-path' => Proc.new { Settings.read('notifier mailer - from').scan(EXTRACT_EMAIL_ADDRESS_REGEX)[0] }

  helper_method :inspect_object

  def contact_form_submission(contact, to)
    @contact = contact
    mail ({
      :subject => build_subject("Contact Form Submission"),
      :to => to,
      :reply_to => "\"#{@contact.name}\" <#{@contact.email_address}>"
    })
  end

  def reminder_failed(email_reminder, exception)
    @email_reminder = email_reminder
    @exception = exception
    mail ({
      :subject => build_subject('Reminder Email Failed'),
      :to => Settings.read('notifier mailer - send failed reminder to'),
    })
  end

  def exception(exception, environment)
    require 'pp'
    @exception = exception
    @environment = environment
    @request = ActionDispatch::Request.new(environment)
    mail ({
      :subject => build_subject('An Exception Occured'),
      :to => Settings.read('notifier mailer - send exception to'),
    })
  end

  def email_list_changed(email_list)
    @email_list = email_list
    @section = Osm::Section.get(@email_list.user.osm_api, @email_list.section_id)
    mail ({
      :subject => build_subject('Email List Changed'),
      :to => @email_list.user.email_address_with_name
    })
  end

  private
  def inspect_object(object)
    case object
    when Hash, Array
      object.inspect
    when ActionController::Base
      "#{object.controller_name}##{object.action_name}"
    else
      object.to_s
    end
  end

end
