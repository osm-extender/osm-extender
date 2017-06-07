class NotifierMailer < ApplicationMailer
  helper_method :inspect_object

  def self.options=(options)
    fail ArgumentError 'options is not a Hash' unless options.is_a?(Hash)
    [:contact_form__to, :reminder_failed__to, :exception__to].each do |option|
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

  def reminder_failed(email_reminder, exception)
    if @@options[:reminder_failed__to]
      @email_reminder = email_reminder
      @exception = exception
      mail ({
        :subject => build_subject('Reminder Email Failed'),
        :to => @@options[:reminder_failed__to],
      })
    end
  end

  def exception(exception, environment, session)
    if @@options[:exception__to]
      @exception = exception
      @environment = environment
      @request = ActionDispatch::Request.new(environment)
      @session = session
      mail ({
        :subject => build_subject('An Exception Occured'),
        :to => @@options[:exception__to],
      })
    end
  end

  def rake_exception(task, exception)
    if @@options[:exception__to]
      @task = task
      @exception = exception
      mail ({
        :subject => build_subject('An Exception Occured in a Rake Task'),
        :to => @@options[:exception__to],
      })
    end
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
