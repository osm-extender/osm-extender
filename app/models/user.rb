class User < ActiveRecord::Base
  authenticates_with_sorcery!  
  
  attr_accessible :name, :email_address, :password, :password_confirmation

  before_save :email_is_lowercase, :send_email_on_attribute_changes

  validates_presence_of :name

  validates_presence_of :email_address
  validate :email_is_unique
  validates_format_of :email_address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'does not look like an email address'

  validates_presence_of :password, :unless => Proc.new { |record| record.send(sorcery_config.password_attribute_name).nil? }
  validates_confirmation_of :password, :unless => Proc.new { |record| record.send(sorcery_config.password_attribute_name).nil? }
  validate :password_complexity, :password_not_email_address, :password_not_name, :unless => Proc.new { |record| record.send(sorcery_config.password_attribute_name).nil? }


  def change_password!(new_password, new_password_confirmation=new_password)
    self.password = new_password
    self.password_confirmation = new_password_confirmation

    if valid? && errors.none?
      if super(new_password)
        UserMailer.password_changed(self).deliver
        return true
      else
        return false
      end
    else
      return false
    end
  end

  
  private
  # Use Steve Gibson's Password Haystacks logic to ensure password is sufficently secure
  # https://www.grc.com/haystack.htm
  # As of 5th October 2011, a haystack of 6 x 10^15 gives:
  # * Online attack: 2 thousand centuries
  # * Offline fast: 18 hours
  # * Massive array: 1 minute
  def password_complexity
    minimum_haystack = 6 * (10**18)
    pass = send(sorcery_config.password_attribute_name)

    alphabet_size = 0
    alphabet_size += 26 if pass.gsub(/[^a-z]/, '').length > 0
    alphabet_size += 26 if pass.gsub(/[^A-Z]/, '').length > 0
    alphabet_size += 10 if pass.gsub(/[^0-9]/, '').length > 0
    alphabet_size += 33 if pass.gsub(/[a-zA-Z0-9]/, '').length > 0

    haystack_size = alphabet_size * (alphabet_size+1)**(pass.length-1)

    if haystack_size < 6 * (10**15)
      errors.add(:password, "isn't complex enough, try increasing its length or adding more types of character (upper case, lower case, numeric and symbol)")
    end

    return haystack_size
  end
  
  def password_not_email_address
    if send(sorcery_config.password_attribute_name).downcase.strip.eql?(email_address.downcase.strip)
      errors.add(:password, 'is not allowed to be your email address')
      return false
    end
    return true
  end

  def password_not_name
    block_size = 2
    name = self.name.downcase
    pass = send(sorcery_config.password_attribute_name).downcase
    for i in 0..(name.length - block_size)
      find = name[i..(i+(block_size-1))]
      if pass.include?(find)
        errors.add(:password, 'is not allowed to contain part of your name')
        return false
      end
    end
    return true
  end

  def email_is_unique
    # Required as 'apple' and 'AppLE' are seen as different
    user_with_email_address = User.find_by_email_address(self.email_address.downcase)
    unless user_with_email_address.nil?  ||  user_with_email_address == self
      errors.add(:email_address, 'has already been taken')
    end
  end

  def email_is_lowercase
    email_address.downcase!
  end

  def send_email_on_attribute_changes
    unless new_record?
      UserMailer.email_address_changed(self).deliver if email_address_changed?
      UserMailer.account_locked(self).deliver if lock_expires_at_changed? && !lock_expires_at.nil?
    end
  end

  public
  # fix sorcery bug involving sqlite
  def self.load_from_token(token, token_attr_name, token_expiration_date_attr)
    return nil if token.blank?
    user = User.find_by_sql("SELECT * from users WHERE trim(#{token_attr_name}) = '#{token}'").first
    if !user.blank? && !user.send(token_expiration_date_attr).nil?
      return Time.now.utc < user.send(token_expiration_date_attr) ? user : nil
    end
    user
  end
  
end
