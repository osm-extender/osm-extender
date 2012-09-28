class Announcement < ActiveRecord::Base

  attr_accessible :start, :finish, :message, :prevent_hiding, :public

  has_many :hidden_announcements, :dependent => :destroy
  has_many :emailed_announcements, :dependent => :destroy

  scope :ignoring, ->(ids) { ids.size > 0 ? where("id not in (#{ ids.map{|id| id.to_i}.join(',') })") : nil }
  scope :are_current, :conditions => 'start <= current_timestamp AND finish >= current_timestamp'
  scope :are_public, :conditions => {:public => true}
  scope :are_hideable, :conditions => {:prevent_hiding => false}

  validates_presence_of :message
  validates_presence_of :start
  validates_presence_of :finish


  def allow_hiding?
    !prevent_hiding
  end


  def self.email_announcement(id)
    announcement = find(id)
    users = User.all
    success = true

    users.each do |user|
      unless user.emailed_announcements.pluck(:announcement_id).include?(announcement.id)
        # We've not already sent to this user
        if announcement.email_announcement_to(user)
          # It sent successfully
          user.emailed_announcements.create(:announcement => announcement)
          success &&= true
        end
      end
    end

    if success # We've sent to everyone we should have
      announcement.emailed_at = Time.now
      announcement.save
    end
  end

  def email_announcement_to(user)
    UserMailer.announcement(user, self).deliver
  end


  def self.delete_old(older_than=6.months.ago)
    if older_than.is_a?(String)
      older_than = older_than.split.inject { |count, unit| count.to_i.send(unit) }
    end
    destroy_all ['updated_at <= ? AND finish <= ?', older_than, older_than]
  end

end
