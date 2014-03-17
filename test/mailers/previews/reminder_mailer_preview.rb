class ReminderMailerPreview < ActionMailer::Preview

  def failed
    reminder = EmailReminder.new(
      section_name: 'A-SECTION',
      user: User.new(
        name: 'Jane Doe',
        email_address: 'jane.doe@example.com'
      )
    )
    ReminderMailer.failed(reminder)
  end

  def shared_with_you
    share = EmailReminderShare.new(
      id: 0,
      name: 'John Smith',
      email_address: 'john.smith@example.com',
      reminder: EmailReminder.new(
        section_name: 'A-SECTION',
        send_on: rand(7),
        user: User.new(
          name: 'Jane Doe'
        ),
        items: [EmailReminderItemBirthday.new, EmailReminderItemNotepad.new]
      )
    )
    ReminderMailer.shared_with_you(share)
  end

  def subscribed
    share = EmailReminderShare.new(
      id: 0,
      name: 'John Smith',
      email_address: 'john.smith@example.com',
      reminder: EmailReminder.new(
        section_name: 'A-SECTION',
        send_on: rand(7),
        user: User.new(
          name: 'Jane Doe'
        )
      )
    )
    ReminderMailer.subscribed(share)
  end

  def unsubscribed
    share = EmailReminderShare.new(
      id: 0,
      name: 'John Smith',
      email_address: 'john.smith@example.com',
      reminder: EmailReminder.new(
        section_name: 'A-SECTION',
        send_on: rand(7),
        user: User.new(
          name: 'Jane Doe'
        )
      )
    )
    ReminderMailer.unsubscribed(share)
  end

end
