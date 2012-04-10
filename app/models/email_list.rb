class EmailList < ActiveRecord::Base
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
    @emails = Array.new
    members = user.osm_api.get_members(section_id)[:data]
    members.each do |member|
      if ((match_grouping == 0) || (member.grouping_id == match_grouping)) ==  match_type
        [:email1, :email2, :email3, :email4].each do |emailN|
          email = member.send(emailN)
          @emails.push email if self.send(emailN) && !email.blank? && !@emails.include?(email)
        end
      end
    end
    return @emails
  end


  private
  def match_grouping_ok
    errors.add(:match_grouping, "Can't be negative") if (match_grouping < 0  &&  ![-2].include?(match_grouping))
  end

end
