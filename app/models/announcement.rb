class Announcement < ActiveRecord::Base
  has_paper_trail

  has_many :hidden_announcements, :dependent => :destroy
  has_many :emailed_announcements, :dependent => :destroy

  scope :ignoring, ->(ids) { where.not(id: ids.map{|id| id.to_i}) }
  scope :are_current, -> { where('start <= current_timestamp AND finish >= current_timestamp')}
  scope :are_public, -> { where public: true }
  scope :are_hideable, -> { where prevent_hiding: false }

  validates_presence_of :message
  validates_presence_of :start
  validates_presence_of :finish

  define_attribute_methods # Can be removed once date_time_attribute issue 2 is closed - https://github.com/einzige/date_time_attribute/issues/2
  date_time_attribute :start
  date_time_attribute :finish


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
