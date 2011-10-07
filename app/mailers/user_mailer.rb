class UserMailer < ActionMailer::Base
  default from: "website@aberdeen-sas.org.uk"

  def activation_needed(user)
    @user = user
    @url  = "http://127.0.0.1:3000/activate_account/#{user.activation_token}"
    mail :subject => 'Section Management System - Activate Your Account', :to => user.send_to_email_address
  end

  def activation_success(user)
    @user = user
    mail :subject => 'Section Management System - Your Account Has Been Activated', :to => user.send_to_email_address
  end

  def reset_password(user)
    @user = user
    @url  = "http://127.0.0.1:3000/reset_password/#{user.reset_password_token}"
    mail :subject => 'Section Management System - Password Reset', :to => user.send_to_email_address
  end

  def password_changed(user)
    @user = user
    mail :subject => 'Section Management System - Password Changed', :to => user.send_to_email_address
  end

end
