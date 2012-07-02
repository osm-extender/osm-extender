class FaqTaging < ActiveRecord::Base
  attr_accessible :faq, :tag, :position

  belongs_to :tag, :class_name => 'FaqTag', :inverse_of => :tagings
  belongs_to :faq, :inverse_of => :tagings

  validates_presence_of :tag
  validates_presence_of :faq

  validates_uniqueness_of :faq_id, :scope => :tag_id

  validates_numericality_of :position, :only_integer=>true, :greater_than_or_equal_to=>0

  acts_as_list

end
