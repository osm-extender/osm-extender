class ProgrammeReviewBalancedCache < ActiveRecord::Base

  serialize :data, Hash

  validates_presence_of :term_id
  validates_presence_of :term_name
  validates_presence_of :term_start
  validates_presence_of :term_finish
  validates_presence_of :section_id  
  validates_presence_of :data
  validates_presence_of :last_used_at

  scope :for_section, ->(section) { where section_id: section.to_i }

end
