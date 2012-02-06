class ProgrammeReviewBalancedCache < ActiveRecord::Base
  attr_accessible :term_id, :section_id, :zone_totals, :method_totals

  serialize :zone_totals, Hash
  serialize :method_totals, Hash

  validates_presence_of :term_id
  validates_presence_of :section_id
  validates_presence_of :zone_totals
  validates_presence_of :method_totals

  def self.delete_old(older_than=1.year.ago)
    self.destroy_all(['updated_at <= ?', older_than])
  end
end
