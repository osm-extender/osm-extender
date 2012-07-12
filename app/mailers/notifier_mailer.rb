class NotifierMailer < ApplicationMailer
  default from: Settings.read('notifier mailer - from')
  helper_method :inspect_object

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
