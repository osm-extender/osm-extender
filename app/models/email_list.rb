class EmailList < ActiveRecord::Base
  has_paper_trail :on => [:create, :update]

  belongs_to :user

  validates_presence_of :user
  validates :notify_changed, :inclusion => {:in => [true, false]}

  validates_presence_of :section_id
  validates_numericality_of :section_id, :only_integer=>true, :greater_than_or_equal_to=>0

  validates_presence_of :name
  validates :contact_member, :inclusion => {:in => 0..4}
  validates :contact_primary, :inclusion => {:in => 0..4}
  validates :contact_secondary, :inclusion => {:in => 0..4}
  validates :contact_emergency, :inclusion => {:in => 0..3}
  validates :match_type, :inclusion => {:in => [true, false]}

  validates_presence_of :match_grouping
  validates_numericality_of :match_grouping, :only_integer=>true
  validate :match_grouping_ok
  validate :at_least_one_contact

  before_save :set_hash_of_addresses
  before_destroy { versions.destroy_all }


  def get_list
    emails = Array.new
    no_emails = Array.new
    section = Osm::Section.get(user.osm_api, section_id)
    fail Osm::Forbidden if section.nil?

    Osm::Member.get_for_section(user.osm_api, section).each do |member|
      next unless ((match_grouping == 0) || (member.grouping_id == match_grouping)) ==  match_type

      methods = {1 => :email_1, 2 => :email_2, 3 => :all_emails, 4 => :enabled_emails}
      member_emails = []
      [
        [:contact, methods[contact_member]],
        [:primary_contact, methods[contact_primary]],
        [:secondary_contact, methods[contact_secondary]],
        [:emergency_contact, methods[contact_emergency]],
      ].each do |(cont, meth)|
        member_emails.push(*member.try(cont).try(meth)) unless meth.nil?
      end
      member_emails.select!{ |i| !i.blank? }

      if member_emails.empty?
        no_emails.push member.name
      else
        emails.push *member_emails
      end
    end # each member

    return {
      :emails => emails.map{ |e| e.downcase }.uniq,
      :no_emails => no_emails.uniq
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

  def at_least_one_contact
    errors.add(:base, "At least one contact must have some addresses selected") if [contact_member, contact_primary, contact_secondary, contact_emergency].uniq.eql?([0])
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
