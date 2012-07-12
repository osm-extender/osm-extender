class EmailReminderShare < ActiveRecord::Base

  attr_accessible :email_address, :name
  attr_accessible :reminder, :email_address, :name, :state, :as => :admin

  belongs_to :reminder, :class_name => 'EmailReminder'

  scope :shared_with, lambda { |email_address| { :conditions => ['email_address LIKE ?', (email_address.is_a?(String) ? email_address : email_address.email_address)] } }

  validates_presence_of :state
  validate :state_is_valid, :forbid_changing_state_back_to_pending

  validates_presence_of :name

  validates_presence_of :reminder

  validates_presence_of :email_address
  validates_uniqueness_of :email_address, :case_sensitive => false, :scope => :reminder_id
  validates :email_address, :email_format => true

  after_initialize :provide_defaults
  before_save :set_was_new
  after_save :email_sharee


  def subscribed?
    read_attribute(:state).to_sym == :subscribed
  end
  def unsubscribed?
    read_attribute(:state).to_sym == :unsubscribed
  end
  def pending?
    read_attribute(:state).to_sym == :pending
  end

  def name
    user = User.find_by_email_address(read_attribute(:email_address).try(:downcase))
    user.nil? ? read_attribute(:name) : user.name
  end


  private
  def provide_defaults
    if new_record?
      write_attribute :state, (state_is_valid? ? read_attribute(:state).to_sym : :pending)
      write_attribute :auth_code, SecureRandom.hex(64) 
    end
  end

  def state_is_valid
    unless state_is_valid?
      errors.add(:state, 'is not a valid state')
    end
  end
  def state_is_valid?(state = read_attribute(:state))
    [:pending, :subscribed, :unsubscribed].include?(state.to_sym)
  end

  def forbid_changing_state_back_to_pending
    if self.state_changed?  &&  (self.state_change.try(:last) == :pending)  &&  !(self.state_change.try(:first).nil? || self.state_change.try(:first).downcase.to_sym == :pending)
      errors[:state] = 'can not be changed back to pending'
    end
  end

  def set_was_new
    @was_new = new_record?
    return true
  end

  def email_sharee
    if @was_new
      ReminderMailer.shared_with_you(self).deliver
    end

    if self.state_changed?
      new_state = state_change.last.to_sym
      ReminderMailer.send(state, self).deliver unless state == :pending
    end

    return true
  end

end
