class SettingValue < ActiveRecord::Base
  audited

  attr_accessible :key, :value, :description

  validates_presence_of :key
  validates_uniqueness_of :key

  validates_presence_of :description
end
