class EmailReminderMailer < ApplicationMailer

  def reminder_email(reminder, data, send_to)
    @reminder = reminder
    @data = data
    @share = send_to[:share]

    mail ({
      :subject => build_subject("Reminder Email for #{@reminder.section_name}"),
      :to => "\"#{send_to[:name]}\" <#{send_to[:email_address]}>",
    })
  end

  def failed(reminder)
    @reminder = reminder

    mail ({
      :subject => build_subject("Reminder Email for #{@reminder.section_name} Failed"),
      :to => @reminder.user.email_address_with_name
    })
  end


  def shared_with_you(share)
    @share = share
    mail ({
      :subject => build_subject("A Reminder Email for #{@share.reminder.section_name} was Shared With You"),
      :to => "\"#{@share.name}\" <#{@share.email_address}>",
    })
  end

  def subscribed(share)
    @share = share
    mail ({
      :subject => build_subject("Subscribed to reminder for #{@share.reminder.section_name} on #{Date::DAYNAMES[@share.reminder.send_on]}"),
      :to => "\"#{@share.name}\" <#{@share.email_address}>",
    })
  end

  def unsubscribed(share)
    @share = share
    mail ({
      :subject => build_subject("Unsubscribed from reminder for #{@share.reminder.section_name} on #{Date::DAYNAMES[@share.reminder.send_on]}"),
      :to => "\"#{@share.name}\" <#{@share.email_address}>",
    })
  end

  def no_current_term(reminder, exception)
    @reminder = reminder
    user = reminder.user

    unless user.nil? || !user.connected_to_osm? || @reminder.section_id.nil?
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
      :subject => build_subject('Preparing Email Reminder FAILED'),
      :to => @reminder.user.email_address_with_name
    })
  end

  def forbidden(reminder, exception)
    @reminder = reminder

    mail ({
      :subject => build_subject('Preparing Email Reminder FAILED'),
      :to => @reminder.user.email_address_with_name
    })
  end

end
