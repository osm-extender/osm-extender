class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_paper_trail :skip => [:crypted_password, :salt, :activation_token, :reset_password_token]

  has_many :email_reminders, dependent: :destroy, inverse_of: :user
  has_many :email_reminder_shares, through: :email_reminders, source: :shares
  has_many :email_lists, dependent: :destroy, inverse_of: :user
  has_many :automation_tasks, dependent: :destroy, inverse_of: :user
  has_many :hidden_announcements, dependent: :destroy, inverse_of: :user
  has_many :emailed_announcements, dependent: :destroy, inverse_of: :user
  has_many :usage_log, inverse_of: :user
  has_many :sessions, inverse_of: :user

  scope :activated, -> { where(sorcery_config.activation_state_attribute_name => 'active') }
  scope :unactivated, -> { where(sorcery_config.activation_state_attribute_name => 'pending') }
  scope :activation_expired, -> { unactivated.where("\"#{sorcery_config.activation_token_expires_at_attribute_name}\" < ?", Time.now) }
  scope :connected_to_osm, -> { where.not(osm_userid: nil, osm_secret: nil) }
  scope :not_connected_to_osm, -> { where(osm_userid: nil, osm_secret: nil) }

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

  validates_acceptance_of :gdpr_consent, on: :create

  before_save :set_gdpr_consent_timestamp, if: Proc.new { |r| r.gdpr_consent.eql?('1') }

  def change_password!(new_password, new_password_confirmation=new_password)
    self.password = new_password
    self.password_confirmation = new_password_confirmation

    if valid? && errors.none? && super(new_password)
      return true
    end
    return false
  end


  def activated?
    send(sorcery_config.activation_state_attribute_name).eql?('active')
  end

  def unactivated?
    send(sorcery_config.activation_state_attribute_name).eql?('pending')
  end


  def connected_to_osm?
    osm_userid.present? && osm_secret.present?
  end

  def not_connected_to_osm?
    !connected_to_osm?
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


  def deliver_reset_password_instructions!(options={})
    config = sorcery_config
    # hammering protection
    return false if config.reset_password_time_between_emails.present? && self.send(config.reset_password_email_sent_at_attribute_name) && self.send(config.reset_password_email_sent_at_attribute_name) > config.reset_password_time_between_emails.seconds.ago.utc
    self.class.sorcery_adapter.transaction do
      generate_reset_password_token!
      if options[:expiration]
        self.reset_password_token_expires_at = options[:expiration].seconds.from_now
        self.save!
      end
      send_reset_password_email! unless config.reset_password_mailer_disabled
    end
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
      all
    end
  end


  # Check if the user and API have a given OSM permission
  # @param section the section to check
  # @param permission_to the action which is being checked (:read or :write), this can be an array in which case the user must be able to perform all actions to the object
  # @param permission_on the object type which is being checked (:member, :register ...), this can be an array in which case the user must be able to perform the action to all objects
  def has_osm_permission?(section, permission_to, permission_on)
    user_can = user_has_osm_permission?(section, permission_to, permission_on)
    api_can = api_has_osm_permission?(section, permission_to, permission_on)
    return user_can && api_can
  end

  # Check if the user has a given OSM permission
  def user_has_osm_permission?(section, permission_to, permission_on)
    permissions = osm_api.get_user_permissions[section.to_i] || {}
    [*permission_on].each do |on|
      [*permission_to].each do |to|
        unless (permissions[on] || []).include?(to)
          return false
        end
      end
    end
    return true
  end

  # Check if the API has a given OSM permission
  def api_has_osm_permission?(section, permission_to, permission_on)
    permissions = Osm::ApiAccess.get_ours(osm_api, section).permissions
    [*permission_on].each do |on|
      [*permission_to].each do |to|
        unless (permissions[on] || []).include?(to)
          return false
        end
      end
    end
    return true
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

    haystack_size = alphabet_size**pass.length

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

  def set_gdpr_consent_timestamp
    return unless gdpr_consent.eql?('1')
    write_attribute :gdpr_consent_at, Time.now.utc
  end

  public
  def clear_reset_password_token
    super
  end

end
