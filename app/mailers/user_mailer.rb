class UserMailer < ApplicationMailer
  default from: Settings.read('user mailer - from')


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


  # Patch as Sorcery doesn't allow a class 'between' this and ApplicationMailer
  def self.superclass
    return ApplicationMailer.superclass
  end


  private
  def build_email_address(address=@user.email_address)
    return "\"#{@user.name}\" <#{address}>"
  end

end
