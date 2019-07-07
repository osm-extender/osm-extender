class ContactUsController < ApplicationController
  helper_method :recaptcha?

  skip_before_action :require_login
  skip_before_action :require_gdpr_consent

  def form
    @contact = ContactUs.new
    if current_user
      @contact.email_address = current_user.email_address
      @contact.name = current_user.name
    end
  end

  def send_form
    @contact = ContactUs.new(sanatised_params.contact_us)

    if (recaptcha_ok? && @contact.valid?) && @contact.send_contact
      redirect_back_or_to root_path, :notice => 'Your message was sent.'
    else
      render :form
    end
  end

  private

  # ReCAPTCHA required?
  def recaptcha?
    return false if current_user
    !!Recaptcha.configuration.site_key
  end

  def recaptcha_ok?
    return true unless recaptcha?
    verify_recaptcha(:model=>@contact)
  end
end
