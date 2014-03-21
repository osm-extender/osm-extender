class EmailList < ActiveRecord::Base
  has_paper_trail

  belongs_to :user

  validates_presence_of :user
  validates :notify_changed, :inclusion => {:in => [true, false]}

  validates_presence_of :section_id
  validates_numericality_of :section_id, :only_integer=>true, :greater_than_or_equal_to=>0

  validates_presence_of :name
  validates :email1, :inclusion => {:in => [true, false]}
  validates :email2, :inclusion => {:in => [true, false]}
  validates :email3, :inclusion => {:in => [true, false]}
  validates :email4, :inclusion => {:in => [true, false]}
  validates :match_type, :inclusion => {:in => [true, false]}

  validates_presence_of :match_grouping
  validates_numericality_of :match_grouping, :only_integer=>true
  validate :match_grouping_ok

  before_save :set_hash_of_addresses


  def get_list
    emails = Array.new
    no_emails = Array.new

    section = Osm::Section.get(user.osm_api, section_id)
    raise Osm::Forbidden if section.nil?
    Osm::Member.get_for_section(user.osm_api, section).each do |member|
      if ((match_grouping == 0) || (member.grouping_id == match_grouping)) ==  match_type
        added_address_for_member = false
        [:email1, :email2, :email3, :email4].each do |emailN|
          email = member.send(emailN).downcase
          if self.send(emailN) && !email.blank?
          #  collecting this email?  not blank
            emails.push email unless emails.include?(email)
            added_address_for_member = true
          end
        end
        no_emails.push member.name unless added_address_for_member
      end
    end

    return {
      :emails => emails,
      :no_emails => no_emails
    }
  end

  def section
    return @section unless @section.nil?
    user.connected_to_osm? ? @section ||= Osm::Section.get(user.osm_api, section_id) : nil
  end
  def section=(new_section)
    write_attribute(:section_id, new_section.to_i)
    @section = new_section
  end

  def get_hash_of_addresses
   return Digest::SHA256.hexdigest(get_list[:emails].sort.inspect)
  end

  private
  def match_grouping_ok
    errors.add(:match_grouping, "Can't be negative") if (match_grouping < 0  &&  ![-2].include?(match_grouping))
  end

  def set_hash_of_addresses
    if notify_changed_changed? && !notify_changed_change[0] && notify_changed_change[1]
      # Turned change notification Off to On
      write_attribute(:last_hash_of_addresses, get_hash_of_addresses)
    end
    if notify_changed_changed? && notify_changed_change[0] && !notify_changed_change[1]
      # Turned change notification On to Off
      write_attribute(:last_hash_of_addresses, '')
    end
  end

end
