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

  def rake_exception(task, exception)
    @task = task
    @exception = exception
    mail ({
      :subject => build_subject('An Exception Occured in a Rake Task'),
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

  def email_list_changed__no_current_term(email_list, exception)
    @email_list = email_list
    @section = Osm::Section.get(@email_list.user.osm_api, @email_list.section_id)
    user = @email_list.user

    unless user.nil? || !user.connected_to_osm? || @email_list.section_id.nil?
      api = user.osm_api
      @next_term = nil
      @last_term = nil
      terms = Osm::Term.get_for_section(api, @section)
      terms.each do |term|
        @last_term = term if term.past? && (@last_term.nil? || term.finish > @last_term.finish)
        @next_term = term if term.future? && (@next_term.nil? || term.start < @next_term.start)
      end
    end

    mail ({
      :subject => build_subject('Checking Email List For Changes FAILED'),
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
