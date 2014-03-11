class UserMailerPreview < ActionMailer::Preview

  def activation_needed
    UserMailer.activation_needed(fake_user)
  end

  def activation_success
    UserMailer.activation_success(fake_user)
  end

  def reset_password
    UserMailer.reset_password(fake_user)
  end

  def locked
    UserMailer.locked(fake_user)
  end

  def announcement
    announcement = Announcement.new(
      message: Faker::Lorem.paragraph(3)
    )
    UserMailer.announcement(fake_user, announcement)
  end

  def send_email
    subject = Faker::Lorem.sentence
    body = Faker::Lorem.paragraph
    UserMailer.send_email(fake_user, subject, body)
  end

  private
  def fake_user
    @fake_user ||= User.new do |u|
      u.name = 'user-mailer-preview'
      u.email_address = "#{u.name}@example.com"
      u.failed_logins_count = User.sorcery_config.consecutive_login_retries_amount_limit
      u.lock_expires_at = User.sorcery_config.login_lock_time_period.seconds.from_now
      u.unlock_token = 'UNLOCK-TOKEN'
      u.reset_password_token = 'RESET-PASSWORD-TOKEN'
      u.activation_token = 'ACTIVATION-TOKEN'
    end
  end

end

