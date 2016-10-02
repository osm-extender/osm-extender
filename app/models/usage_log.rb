class UsageLog < ActiveRecord::Base
  belongs_to :user

  serialize :extra_details, Hash

  validates_presence_of :user
  validates_presence_of :controller
  validates_presence_of :action
  validates_presence_of :at
  validates_presence_of :at_hour
  validates_presence_of :at_day_of_week

  before_validation :set_times, :on => :create
  before_update { fail ActiveRecord::ReadOnlyRecord }
  before_destroy { fail ActiveRecord::ReadOnlyRecord }


  private
  def set_times
    now = Time.now.utc
    self.at = now
    self.at_hour = now.hour
    self.at_day_of_week = now.wday
  end

end
