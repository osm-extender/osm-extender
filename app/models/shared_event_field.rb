class SharedEventField < ActiveRecord::Base
  has_paper_trail
##  audited :associated_with => :shared_event
##  has_associated_audits

  belongs_to :event, :class_name => SharedEvent, :foreign_key => :shared_event_id
  belongs_to :shared_event
  has_many :data_sources, :dependent => :destroy, :class_name => SharedEventFieldData

  validates_presence_of :shared_event
  validates_presence_of :name

  validates_uniqueness_of :name, :case_sensitive => false, :scope => :shared_event_id
end
