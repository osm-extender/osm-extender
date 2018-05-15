class UserMailer < ApplicationMailer
  helper ApplicationHelper

  default **get_defaults(
    name: Figaro.env.automation_task_from_name? ? Figaro.env.automation_task_from_name : 'OSM Extender',
    mailname: Figaro.env.automation_task_from_mailname? ? Figaro.env.automation_task_from_mailname : 'system',
  )

  def activation_needed(user)
    @user = user
    mail ({
      :subject => build_subject('Activate Your Account'),
      :to => @user.email_address_with_name
    })
  end

  def activation_success(user)
    @user = user
    mail ({
      :subject => build_subject('Your Account Has Been Activated'),
      :to => @user.email_address_with_name
    })
  end

  def reset_password(user)
    @user = user
    mail ({
      :subject => build_subject('Password Reset'),
      :to => @user.email_address_with_name
    })
  end

  def locked(user)
    @user = user
    mail ({
      :subject => build_subject('Account Locked'),
      :to => @user.email_address_with_name
    })
  end

  def announcement(user, announcement)
    @user = user
    @announcement = announcement
    mail ({
      :subject => build_subject("Announcement#{ " - #{announcement.title}" unless announcement.title.empty? }"),
      :to => @user.email_address_with_name
    })
  end

  def send_email(user, subject, body)
    @user = user
    @body = body
    mail ({
      :subject => build_subject(subject),
      :to => @user.email_address_with_name
    })
  end

end
