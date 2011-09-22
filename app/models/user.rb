class User < ActiveRecord::Base
  authenticates_with_sorcery!  
  
  attr_accessible :name, :email_address, :password, :password_confirmation

  validates_presence_of :name

  validates_presence_of :email_address
  validates_uniqueness_of :email_address
  validates_format_of :email_address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'does not look like an email address'
  
  validates_presence_of :password, :on=>:create
  validates_confirmation_of :password, :on=>:create
  validates_length_of :password, :minimum=>8, :on=>:create
  validate :password_different_types?, :password_not_email_address?, :on=>:create
  
  
  def change_password!(new_password, new_password_confirmation=new_password)
    if !new_password.eql?(new_password_confirmation)
      errors.add(:password_confirmation, 'does not match')
      return false
# TODO Also check password validations
    elsif self.password.valid?
      return super(new_password)
    else
      errors.add(:password, 'validation errors occured')
      return false
    end
  end

  
  private
  def password_different_types?
puts 'CHECK: password_different_types?'
    require_different_types = 2
    lower_case = password.gsub(/[^a-z]/, '').length
    upper_case = password.gsub(/[^A-Z]/, '').length
    numeric = password.gsub(/[^0-9]/, '').length
    other = password.length - (lower_case + upper_case + numeric)

    types = (lower_case == 0) ? 0 : 1
    types += (upper_case == 0) ? 0 : 1
    types += (numeric == 0) ? 0 : 1
    types += (other == 0) ? 0 : 1

    if types < require_different_types
      errors.add(:password, "does not use at least #{require_different_types} different types of character, you used #{types}")
      return false
    else
      return true
    end
  end
  
  def password_not_email_address?
puts 'CHECK: password_not_email_address?'
    if password.eql?(email_address)
      errors.add(:password, 'is not allowed to be your email address')
      return false
    else
      return true
    end
  end
  
end
