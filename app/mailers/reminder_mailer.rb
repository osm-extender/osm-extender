class ReminderMailer < ApplicationMailer
  default from: Proc.new { Settings.read('reminder mailer - from') },
          'return-path' => Proc.new { Settings.read('reminder mailer - from').scan(EXTRACT_EMAIL_ADDRESS_REGEX)[0] }


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

end
