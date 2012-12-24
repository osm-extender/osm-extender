class ContactUsController < ApplicationController
  skip_before_filter :require_login

  def new
    @contact = ContactUs.new
    if current_user
      @contact.email_address = current_user.email_address
      @contact.name = current_user.name
    end
  end

  def create
    @contact = ContactUs.new(params[:contact_us])

    contact_valid = @contact.valid?
    recaptcha_ok = current_user || verify_recaptcha(:model=>@contact)

    if (recaptcha_ok && contact_valid) && @contact.send_contact
      redirect_back_or_to root_path, :notice => 'Your message was sent.'
    else
      render :new
    end
  end

end