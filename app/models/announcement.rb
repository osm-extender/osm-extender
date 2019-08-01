class Announcement < ApplicationRecord
  has_paper_trail

  has_many :hidden_announcements, dependent: :destroy, inverse_of: :announcement
  has_many :emailed_announcements, dependent: :destroy, inverse_of: :announcement

  scope :ignoring, ->(ids) { where.not(id: ids.map{|id| id.to_i}) }
  scope :are_current, -> { where('start <= current_timestamp AND finish >= current_timestamp')}
  scope :are_public, -> { where public: true }
  scope :are_hideable, -> { where prevent_hiding: false }

  validates_presence_of :message
  validates_presence_of :start
  validates_presence_of :finish

  date_time_attribute :start
  date_time_attribute :finish


  def hideable?
    !prevent_hiding
  end

  def current?
    now = Time.zone.now
    (start < now) && (finish > now)
  end

  def self.email_announcement(id)
    announcement = find(id)

    # Mailgun limits us to 100 message per hour.
    # So queue 1 per minute to trikle them out in batches when the worker runs.
    send_time = Time.now
    User.all.each_slice(100) do |users|
      users.each do |user|
        next if user.emailed_announcements.pluck(:announcement_id).include?(announcement.id)

        send_time += 1.minute
        send_time += 1.hour if send_time.utc.hour == 3 # Add another hour if the scheduled tasks will be running
                                                       # and therefore generating more emails.

        Announcement.delay(run_at: send_time).email_announcement_to(announcement.id, user.id)   # Setup job to send it
      end
    end

    announcement.emailed_at = Time.now
    announcement.save
  end

  def email_announcement_to(user)
    UserMailer.announcement(user, self).deliver_now
  end

  def self.email_announcement_to(announcement, user)
    announcement = Announcement.find(announcement)
    user = User.find(user)
    UserMailer.announcement(user, announcement).deliver_now
    user.emailed_announcements.create(:announcement => announcement)
  end
end
