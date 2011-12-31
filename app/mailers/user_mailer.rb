class UserMailer < ActionMailer::Base
  default from: "\"OSMExtender\" <OSMExtender@robertgauld.co.uk>"

  def activation_needed(user)
    @user = user
    @url  = build_url("/activate_account/#{user.activation_token}")
    mail ({
      :subject => build_subject('Activate Your Account'),
      :to => build_email_address
    })
  end

  def activation_success(user)
    @user = user
    mail ({
      :subject => build_subject('Your Account Has Been Activated'),
      :to => build_email_address
    })
  end

  def reset_password(user)
    @user = user
    @url  = build_url("/reset_password/#{user.reset_password_token}")
    mail ({
      :subject => build_subject('Password Reset'),
      :to => build_email_address
    })
  end

  def password_changed(user)
    @user = user
    mail ({
      :subject => build_subject('Password Changed'),
      :to => build_email_address
    })
  end

  def email_address_changed(user)
    @user = user
    @new_email_address = user.email_address_change[1]
    mail ({
      :subject => build_subject('Email Address Changed'),
      :to => build_email_address(user.email_address_change[0])
    })
  end

  def account_locked(user)
    @user = user
    mail ({
      :subject => build_subject('Account Locked'),
      :to => build_email_address
    })
  end


  private
  def build_subject(subject)
    start = 'OSMExtender'
    start += " (#{Rails.env.upcase})" unless Rails.env.production?
    return "#{start} - #{subject}"
  end

  def build_email_address(address=@user.email_address)
    return "\"#{@user.name}\" <#{address}>"
  end

  def build_url(path)
    return Rails.configuration.root_url.to_s + path
  end

end
