class ContactUs
  include ActiveModel::Model

  attr_accessor :name, :email_address, :message

  validates_presence_of :name

  validates_presence_of :email_address
  validates :email_address, :email_format => true

  validates_presence_of :message


  def send_contact
    if valid?
      return NotifierMailer.contact_form_submission(self).deliver
    else
      return nil
    end
  end

end
