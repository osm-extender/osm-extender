class SettingValue < ActiveRecord::Base
  validates_presence_of :key
  validates_uniqueness_of :key

  validates_presence_of :description
end
