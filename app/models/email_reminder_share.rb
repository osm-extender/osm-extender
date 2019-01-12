class EmailReminderShare < ApplicationRecord
  has_paper_trail :on => [:create, :update]

  belongs_to :reminder, :class_name => 'EmailReminder'

  scope :shared_with, ->(email_address) { where ['email_address LIKE ?', (email_address.is_a?(String) ? email_address : email_address.email_address)] }

  validates_presence_of :state
  validate :state_is_valid, :forbid_changing_state_back_to_pending

  validates_presence_of :name

  validates_presence_of :reminder

  validates_presence_of :email_address
  validates_uniqueness_of :email_address, :case_sensitive => false, :scope => :reminder_id
  validates :email_address, :email_format => true

  after_initialize :provide_defaults
  before_save :set_was_new
  before_save :set_was_state
  after_commit :email_sharee
  before_destroy { versions.destroy_all }


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
    user = User.find_by(email_address: read_attribute(:email_address).try(:downcase))
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
  end

  def set_was_state
    @was_state = state_was
  end

  def email_sharee
    if @was_new
      EmailReminderMailer.shared_with_you(self).deliver_later
    end

    if @was_state != state
      unless state == 'pending'
        EmailReminderMailer.send(state, self).deliver_later
      end
    end
  end
end
