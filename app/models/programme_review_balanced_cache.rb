class ProgrammeReviewBalancedCache < ActiveRecord::Base
##  attr_accessible :term_id, :section_id, :term_name, :term_start, :term_finish, :data, :last_used_at

  serialize :data, Hash

  validates_presence_of :term_id
  validates_presence_of :term_name
  validates_presence_of :term_start
  validates_presence_of :term_finish
  validates_presence_of :section_id  
  validates_presence_of :data
  validates_presence_of :last_used_at

  scope :for_section, ->(section) { where section_id: section.to_i }

  def self.delete_old(older_than=1.year.ago)
    if older_than.is_a?(String)
      older_than = older_than.split.inject { |count, unit| count.to_i.send(unit) }
    end
    destroy_all ['last_used_at <= ?', older_than]
  end

end
