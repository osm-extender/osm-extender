class UsageLog < ActiveRecord::Base
  belongs_to :user

  attr_accessible :at, :controller, :action, :sub_action, :result, :extra_details, :section_id, :user

  serialize :extra_details, Hash

  validates_presence_of :user
  validates_presence_of :at
  validates_presence_of :controller
  validates_presence_of :action

  before_update { raise ActiveRecord::ReadOnlyRecord }
  before_destroy { raise ActiveRecord::ReadOnlyRecord }
end
