class ReminderMailer < ApplicationMailer
  default from: Settings.read('reminder mailer - from')


  def reminder_email(reminder, data, send_to)
    @reminder = reminder
    @data = data

    @share = send_to[:share]
    @share_url = build_url(edit_email_reminder_subscription_path(:id => @share.id, :auth_code => @share.auth_code)) unless @share.nil?

    mail ({
      :subject => build_subject("Reminder Email for #{@reminder.section_name}"),
      :to => "\"#{send_to[:name]}\" <#{send_to[:email_address]}>",
    })
  end

  def failed(reminder)
    @reminder = reminder

    mail ({
      :subject => build_subject("Reminder Email for #{@reminder.section_name} Failed"),
      :to => "\"#{@reminder.user.name}\" <#{@reminder.user.email_address}>",
    })
  end


  def shared_with_you(share)
    @share = share
    @url = build_url(edit_email_reminder_subscription_path(:id => @share.id, :auth_code => @share.auth_code))
    @contact_link = build_url(new_contact_u_path)
    mail ({
      :subject => build_subject("A Reminder Email for #{@share.reminder.section_name} was Shared With You"),
      :to => "\"#{@share.name}\" <#{@share.email_address}>",
    })
  end

  def subscribed(share)
    @share = share
    @url = build_url(edit_email_reminder_subscription_path(:id => @share.id, :auth_code => @share.auth_code))
    mail ({
      :subject => build_subject("Subscribed to reminder for #{@share.reminder.section_name} on #{%w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}[@share.reminder.send_on]}"),
      :to => "\"#{@share.name}\" <#{@share.email_address}>",
    })
  end

  def unsubscribed(share)
    @share = share
    @url = build_url(edit_email_reminder_subscription_path(:id => @share.id, :auth_code => @share.auth_code))
    mail ({
      :subject => build_subject("Unsubscribed from reminder for #{@share.reminder.section_name} on #{%w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}[@share.reminder.send_on]}"),
      :to => "\"#{@share.name}\" <#{@share.email_address}>",
    })
  end

end
