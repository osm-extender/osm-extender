class NotifierMailer < ApplicationMailer
  helper_method :inspect_object

  def self.options=(options)
    raise ArgumentError 'options is not a Hash' unless options.is_a?(Hash)
    [:contact_form__to, :reminder_failed__to, :exception__to].each do |option|
      raise ArgumentError "options must contain a value for :#{option}" unless options.has_key?(option)
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

  def email_list_changed(email_list)
    @email_list = email_list
    mail ({
      :subject => build_subject('Email List Changed'),
      :to => @email_list.user.email_address_with_name
    })
  end

  def email_list_changed__no_current_term(email_list, exception)
    @email_list = email_list
    user = @email_list.user

    unless user.nil? || !user.connected_to_osm? || @email_list.section_id.nil?
      api = user.osm_api
      @next_term = nil
      @last_term = nil
      terms = Osm::Term.get_for_section(api, @email_list.section)
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

  def email_list_changed__forbidden(email_list, exception)
    @email_list = email_list

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
