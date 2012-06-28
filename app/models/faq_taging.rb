class FaqTaging < ActiveRecord::Base
  attr_accessible :faq_id, :faq_tag_id, :position

  belongs_to :faq_tag
  belongs_to :faq

  validates_presence_of :faq_tag
  validates_presence_of :faq

  validates_uniqueness_of :faq_id, :scope => :faq_tag_id

  validates_numericality_of :position, :only_integer=>true, :greater_than_or_equal_to=>0

  acts_as_list

end
