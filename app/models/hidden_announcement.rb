class HiddenAnnouncement < ActiveRecord::Base

##  attr_accessible :user, :announcement

  belongs_to :user
  belongs_to :announcement

end
