class User < ActiveRecord::Base
  authenticates_with_sorcery!

  attr_accessible :name, :email_address, :password, :password_confirmation
  attr_accessible :name, :email_address, :password, :password_confirmation, :can_administer_users, :can_administer_faqs, :as => :admin

  has_many :email_reminders, :dependent => :destroy
  has_many :email_lists, :dependent => :destroy

  before_save :email_is_lowercase
  after_save :send_email_on_attribute_changes

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

    if valid? && errors.none? && super(new_password)
      return true
    end
    return false
  end
  
  
  def locked?
    return false if send(sorcery_config.lock_expires_at_attribute_name).nil?
    return (send(sorcery_config.lock_expires_at_attribute_name) > Time.now)
  end

  def active?
    send(sorcery_config.activation_state_attribute_name).eql?('active')
  end


  def connected_to_osm?
    return (osm_userid.present? && osm_secret.present?)
  end

  def connect_to_osm(email, password)
    api = OSM::API.new
    result = api.authorize(email, password)

    unless result[:http_error] || result[:osm_error]
      write_attribute(:osm_userid, result[:data]['userid'])
      write_attribute(:osm_secret, result[:data]['secret'])
      return save
    else
      errors.add(:connect_to_osm, result[:osm_error]) if result[:osm_error]
      errors.add(:connect_to_osm, "HTTP ERROR #{result[:http_error]}") if result[:http_error]
      return false
    end
  end


  def osm_api
    if connected_to_osm?
      @osm_api ||= OSM::API.new(read_attribute(:osm_userid), read_attribute(:osm_secret))
      return @osm_api
    else
      return nil
    end
  end

  def gravatar_id
    return Digest::MD5.hexdigest(read_attribute(:email_address).downcase)
  end

  def self.search(column, text)
    allowed_columns = [:name, :email_address]

    if !text.blank? && allowed_columns.include?(column)
      text.downcase! if [:email_address].include?(column)
      where(["#{column.to_s} LIKE ?", "%#{text}%"])
    else
      scoped
    end
  end
  
  private
  # Use Steve Gibson's Password Haystacks logic to ensure password is sufficently secure
  # https://www.grc.com/haystack.htm
  # Assume the following guesses per second:
  #  * Online attack - one thousand (10**3)
  #  * Offline attack - one hundred billion (10**11)
  #  * Cracking array - one hundred trillion (10**14)
  def password_complexity
    minimum_haystack = (10**14) # Withstand for 1 second of a massive cracking array
    pass = send(sorcery_config.password_attribute_name)

    alphabet_size = 0
    alphabet_size += 26 if pass.gsub(/[^a-z]/, '').length > 0
    alphabet_size += 26 if pass.gsub(/[^A-Z]/, '').length > 0
    alphabet_size += 10 if pass.gsub(/[^0-9]/, '').length > 0
    alphabet_size += 33 if pass.gsub(/[a-zA-Z0-9]/, '').length > 0

    haystack_size = alphabet_size * (alphabet_size+1)**(pass.length-1)

    if haystack_size < minimum_haystack
      if alphabet_size < 40
        errors.add(:password, "isn't complex enough, try adding more types of character (upper case, lower case, numeric and symbol)")
      end
      if pass.length < 10
        errors.add(:password, "isn't complex enough, try increasing its length")
      end
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
    block_size = 3
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
    if lock_expires_at_changed?
      UserMailer.account_locked(self).deliver unless lock_expires_at.nil?
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
