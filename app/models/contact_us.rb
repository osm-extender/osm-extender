class ContactUs

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :email_address, :message

  validates_presence_of :name

  validates_presence_of :email_address
  validates :email_address, :email_format => true

  validates_presence_of :message

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def send_contact
    if valid?
      return NotifierMailer.contact_form_submission(self).deliver
    else
      return nil
    end
  end

  def persisted?
    false
  end

end
