class EmailList < ActiveRecord::Base
  attr_accessible :user, :name, :section_id, :email1, :email2, :email3, :email4, :match_type, :match_grouping

  belongs_to :user

  validates_presence_of :user

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


  def get_list
    emails = Array.new
    no_emails = Array.new

    Osm::Member.get_for_section(user.osm_api, section_id).each do |member|
      if ((match_grouping == 0) || (member.grouping_id == match_grouping)) ==  match_type
        added_address_for_member = false
        [:email1, :email2, :email3, :email4].each do |emailN|
          email = member.send(emailN)
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


  private
  def match_grouping_ok
    errors.add(:match_grouping, "Can't be negative") if (match_grouping < 0  &&  ![-2].include?(match_grouping))
  end

end
