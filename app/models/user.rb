class User < ActiveRecord::Base
  authenticates_with_sorcery!
  audited :except => [:crypted_password, :salt, :activation_token, :reset_password_token]

  attr_accessible :name, :email_address, :password, :password_confirmation, :startup_section
  attr_accessible :name, :email_address, :password, :password_confirmation, :can_administer_users, :can_view_statistics, :can_administer_announcements, :can_administer_delayed_job, :can_become_other_user, :as => :admin

  has_many :email_reminders, :dependent => :destroy
  has_many :email_reminder_shares, :through => :email_reminders, :source => :shares
  has_many :email_lists, :dependent => :destroy
  has_many :hidden_announcements, :dependent => :destroy
  has_many :emailed_announcements, :dependent => :destroy
  has_many :shared_event_attendances, :dependent => :destroy
  has_many :shared_events, :dependent => :destroy
  has_many :usage_log

  validates_presence_of :name

  validates_presence_of :email_address
  validates_uniqueness_of :email_address, :case_sensitive => false
  validates :email_address, :email_format => true

  validates_presence_of :password, :unless => Proc.new { |record| record.send(sorcery_config.password_attribute_name).nil? }
  validates_confirmation_of :password, :unless => Proc.new { |record| record.send(sorcery_config.password_attribute_name).nil? }
  validate :password_complexity, :password_not_email_address, :password_not_name, :unless => Proc.new { |record| record.send(sorcery_config.password_attribute_name).nil? }

  validates_numericality_of :startup_section, :only_integer=>true, :greater_than_or_equal_to=>0
  validates_numericality_of :custom_row_height, :only_integer=>true, :greater_than_or_equal_to=>0
  validates_numericality_of :custom_text_size, :only_integer=>true, :greater_than_or_equal_to=>0


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
    result = Osm::Api.authorize(email, password)

    write_attribute(:osm_userid, result[:user_id])
    write_attribute(:osm_secret, result[:secret])
    return save
  end

  def osm_api
    if connected_to_osm?
      @osm_api ||= Osm::Api.new(read_attribute(:osm_userid), read_attribute(:osm_secret))
      return @osm_api
    else
      return nil
    end
  end


  def current_announcements
    Announcement.are_current.ignoring(hidden_announcements.pluck(:announcement_id))
  end


  def gravatar_id
    return Digest::MD5.hexdigest(read_attribute(:email_address).downcase)
  end

  def email_address_with_name
    "\"#{name.gsub('"', '')}\" <#{email_address}>"
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

  public
  def clear_reset_password_token
    super
  end

end
